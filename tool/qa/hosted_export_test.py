"""Staging only; private exports and tokens stay in runner memory, never logs/artifacts."""
import os, json, urllib.request, urllib.error, hashlib, base64, sys
BASE='https://hpjzfytwivlpsdhiupyd.supabase.co'
KEY='sb_publishable_XhQBsZ28qqCnZkLzo4WMOg_948v9PIz'
def request(path, token=None, payload=None, raw=None, method="POST"):
    headers={'apikey':KEY}
    if token: headers['Authorization']='Bearer '+token
    if payload is not None: headers['Content-Type']='application/json'
    if raw is not None: headers['Content-Type']='image/png'
    data=raw if raw is not None else (json.dumps(payload).encode() if payload is not None else (None if method=='GET' else b''))
    req=urllib.request.Request(BASE+path,data=data,headers=headers,method=method)
    try:
        with urllib.request.urlopen(req,timeout=35) as response:
            body=response.read(45*1024*1024+1)
            if len(body)>45*1024*1024: raise RuntimeError('response limit')
            return response.status,dict(response.headers),json.loads(body) if body else None
    except urllib.error.HTTPError as error:
        code=None
        if path.startswith('/auth/v1/token?'):
            try:
                reported=json.loads(error.read(4096)).get('error_code')
                if reported in {'invalid_credentials','email_not_confirmed','email_provider_disabled','over_request_rate_limit','user_banned'}:code=reported
            except Exception:pass
        return error.code,{}, {'safe_code':code}

def run():
    email=os.environ.get('STAGING_EXPORT_TEST_EMAIL')
    password=os.environ.get('STAGING_EXPORT_TEST_PASSWORD')
    if not email or not password:
        print('BLOCKED: configure STAGING_EXPORT_TEST_EMAIL and STAGING_EXPORT_TEST_PASSWORD for an existing synthetic staging account.')
        return 2
    token=None
    step='sign-in';status=None
    try:
        status,_,auth=request('/auth/v1/token?grant_type=password',payload={'email':email,'password':password})
        if status!=200:
            print('Auth result: '+str((auth or {}).get('safe_code') or 'unclassified'))
            raise RuntimeError('staging sign-in failed')
        token=auth['access_token'];owner=auth['user']['id']
        step='fixture-upload'
        if owner!='2e0c217b-950b-4122-8fc5-9e37fced985e':raise RuntimeError('unexpected fixture account')
        png=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jG2kAAAAASUVORK5CYII=')
        status,_,_=request('/storage/v1/object/beta-feedback/'+owner+'/export-probe-20261010.png',token,raw=png)
        if status not in (200,201,400,409):raise RuntimeError('fixture upload failed')
        # Existing objects are never overwritten. Export validates the exact fixture hash below.
        step='download' 
        status,headers,export=request('/functions/v1/export-account',token)
        if status!=200: raise RuntimeError('authenticated export failed (check rate interval and fixture)')
        step='validate-export'
        if export['format']!='questwell-account-export': raise RuntimeError('unexpected format')
        if len(export['tables'])!=8: raise RuntimeError('missing record group')
        for table,rows in export['tables'].items():
            if any(row['id' if table=='users' else 'user_id']!=owner for row in rows):raise RuntimeError('owner isolation failed')
        if not export['attachments']: raise RuntimeError('fixture needs a feedback report with a private attachment')
        for item in export['attachments']:
            raw=base64.b64decode(item['data'],validate=True)
            if not item['path'].startswith(owner+'/') or len(raw)!=item['size'] or hashlib.sha256(raw).hexdigest()!=item['sha256']:raise RuntimeError('attachment integrity failed')
        if not any(item['path']==owner+'/export-probe-20261010.png' and item['sha256']==hashlib.sha256(png).hexdigest() for item in export['attachments']):raise RuntimeError('fixture missing or changed')
        if 'no-store' not in {k.lower():v for k,v in headers.items()}.get('cache-control',''):raise RuntimeError('private cache policy missing')
        step='rate-limit'
        status,_,_=request('/functions/v1/export-account',token)
        if status!=429:raise RuntimeError('repeat request not throttled')
        step='logout'
        status,_,_=request('/auth/v1/logout?scope=local',token)
        if status not in (200,204):raise RuntimeError('test-session logout failed')
        step='revoked-session'
        status,_,_=request('/functions/v1/export-account',token)
        if status not in (401,403):raise RuntimeError('old-token denial not verified')
        token=None
        print('PASS: authenticated export, eight owner-scoped groups, nonempty attachment checksums, no-store, rate denial, old-token denial.')
        return 0
    except Exception as error:
        # Never emit HTTP bodies, account identifiers, tokens, paths or export data.
        print(f'FAIL: stage={step}; HTTP={status if isinstance(status,int) else "none"}. No private response logged.')
        return 1
    finally:
        if token:
            try:request('/auth/v1/logout?scope=local',token)
            except Exception:pass
if __name__=='__main__':sys.exit(run())
