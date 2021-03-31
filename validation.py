import os
import sys
import requests

def validate(blueprint, space, token, branch):
    """returns the list of errors"""
    endpoint_url = f"https://cloudshellcolony.com/api/spaces/{space}/validations/blueprints"
    payload = {
        'blueprint_name': blueprint,
        'type': 'sandbox',
        'source': {
            'branch': branch
        }
    }

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Accept-Charset": "utf-8",
        "Authorization": f"Bearer {token}"
    }
    
    resp = requests.post(endpoint_url, data=payload, headers=headers)

    if resp.status_code > 400:
        raise Exception(resp.text)
    
    else:
        return [err['message'] for err in resp.json['errors']]


if __name__ == "__main__":
    bps_to_validate = os.environ.get("BPS_TO_VALIDATE", "")
    branch_name = os.environ.get("BRANCH", "")
    colony_space = os.environ.get("INPUT_SPACE", "")
    colony_token = os.environ.get("INPUT_COLONY_TOKEN", "")

    if not bps_to_validate:
        print("Nothing to do")
        sys.exit(0)

    errors_sum = 0

    for bp_path in bps_to_validate.split(","):
        bp_base = os.path.basename(bp_path)
        bp_name = os.path.splitext(bp_base)[0]
 
        errors = None
  
        try: 
            errors = validate(bp_name, colony_space, colony_token, branch_name)
        except Exception as e:
            print(f"[WARNING] Unable to validate blueprint {bp_name}. Reason: {str(e)}")
            continue
 
        if not errors:
            print(f"The blueprint {bp_name} is valid")
            continue

        else:
            print("[ERROR] The blueprint {bp_name} has the following error(s):")
            print("\n".join(errors))
            errors_sum += 1

    if errors_sum > 0:
        print(f"The total number of failed blueprints: {errors_sum}")
        sys.exit(1)
