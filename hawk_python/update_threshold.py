import json

r = {'mean': 0.4,'upper_bound': 0.5, 'lower_bound': 0.1}
r = json.dumps(r)
print(r)