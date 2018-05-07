import sys
import json

def execute():
	# print(sys.argv[1])
	# print("[{var_a:'lalalahehe', var_b:'jawhka'},{var_a:'lalalahehe', var_b:'jawhka'}]")
	r = {'is_claimed': 'True', 'rating': 3.5}
	r = json.dumps(r)
	print(r)
	# return sys.argv[1]
execute()