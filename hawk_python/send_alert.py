import json

r = {'is_alert': 1,'value': 10, 'is_upper': 1}
r = json.dumps(r)
print(r)