import json

r = {'mean': 0.4,'upper_bound': 0.5, 'lower_bound': 0.1, 'redash_title': 'redash_baru'}
r = json.dumps(r)
print(r)