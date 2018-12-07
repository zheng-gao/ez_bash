import argparse
import requests
import getpass


PARSER = argparse.ArgumentParser(description='Send Python Request')
PARSER.add_argument("--url", dest="url", required=True)
PARSER.add_argument("-x", "--method", dest="method", default="GET", choices=["GET", "POST"])
PARSER.add_argument("-u", "--username", dest="username", default=None)
PARSER.add_argument("-p", "--password", dest="password", default=None)
ARGUMENTS = PARSER.parse_args()


def main(args):
    auth = None
    if args.username is not None:
        if args.password is not None:
            auth = (args.username, args.password)
        else:
            auth = (args.username, getpass.getpass())
    try:
        if args.method == "GET": 
            result = requests.get(url=args.url, auth=auth, timeout=10)
        elif args.method == "POST": 
            result = requests.post(url=args.url, auth=auth, timeout=10)
        result.raise_for_status()
    except Exception as e:
        print(e)
    print("Status Code:")
    print(result.status_code)
    print("Result Text:")
    print(result.text)

if __name__ == "__main__":
    main(args=ARGUMENTS)
