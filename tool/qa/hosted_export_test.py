"""Staging only; private exports and tokens stay in runner memory, never logs/artifacts."""
import os, json, urllib.request, urllib.error, hashlib, base64, sys
BASE='https://hpjzfytwivlpsdhiupyd.supabase.co'
KEY='sb_publishable_XhQBsZ28qqCnZkLzo4WMOg_948v9PIz'
def request(path, token=None, payload=None):
    headers={'apikey':KEY}
    if token: headers['Authorization']='Bearer '+token
    if payload is not None: headers['Content-Type']='application/json'
    data=json.dumps(payload).encode() if payload is not None else b''
    req=urllib.request.Request(BASE+path,data=data,headers=headers,method='POST')
    try:
        with urllib.request.urlopen(req,timeout=35) as response:
            body=response.read(45*1024*1024+1)
            if len(body)>45*1024*1024: raise RuntimeError('response limit')
            return response.status,dict(response.headers),json.loads(body) if body else None
    except urllib.error.HTTPError as error:
        return error.code,{},None

def run():
    email=os.environ.get('STAGING_EXPORT_TEST_EMAIL')
    password=os.environ.get('STAGING_EXPORT_TEST_PASSWORD')
    if not email or not password:
        print('BLOCKED: configure STAGING_EXPORT_TEST_EMAIL and STAGING_EXPORT_TEST_PASSWORD for an existing synthetic staging account.')
        return 2
    token=None
    try:
        status,_,auth=request('/auth/v1/token?grant_type=password',payload={'email':email,'password':password})
        if status!=200: raise RuntimeError('staging sign-in failed')
        token=auth['access_token'];owner=auth['user']['id']
        status,headers,export=request('/functions/v1/export-account',token)
        if status!=200: raise RuntimeError('authenticated export failed (check rate interval and fixture)')
        if export['format']!='questwell-account-export': raise RuntimeError('unexpected format')
        if len(export['tables'])!=8: raise RuntimeError('missing record group')
        for table,rows in export['tables'].items():
            if any(row['id' if table=='users' else 'user_id']!=owner for row in rows):raise RuntimeError('owner isolation failed')
        if not export['attachments']: raise RuntimeError('fixture needs a feedback report with a private attachment')
        for item in export['attachments']:
            raw=base64.b64decode(item['data'],validate=True)
            if not item['path'].startswith(owner+'/') or len(raw)!=item['size'] or hashlib.sha256(raw).hexdigest()!=item['sha256']:raise RuntimeError('attachment integrity failed')
        if 'no-store' not in {k.lower():v for k,v in headers.items()}.get('cache-control',''):raise RuntimeError('private cache policy missing')
        status,_,_=request('/functions/v1/export-account',token)
        if status!=429:raise RuntimeError('repeat request not throttled')
        status,_,_=request('/auth/v1/logout?scope=local',token)
        if status not in (200,204):raise RuntimeError('test-session logout failed')
        status,_,_=request('/functions/v1/export-account',token)
        if status not in (401,403):raise RuntimeError('old-token denial not verified')
        token=None
        print('PASS: authenticated export, eight owner-scoped groups, nonempty attachment checksums, no-store, rate denial, old-token denial.')
        return 0
    except Exception as error:
        # Never emit HTTP bodies, account identifiers, tokens, paths or export data.
        print('FAIL: hosted export checks did not complete. No private response logged.')
        return 1
    finally:
        if token:
            try:request('/auth/v1/logout?scope=local',token)
            except Exception:pass
if __name__=='__main__':sys.exit(run())
