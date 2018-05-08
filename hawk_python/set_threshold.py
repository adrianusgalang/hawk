import json
import sys

from queryBL.hawk import Hawk


def main(argv):
    """

    :param argv:
    :return:
    """
    if len(argv) != 5:
        message = 'need to give 5 arguments (redash_id, time_column, value_column, value_type), given ' + str(len(argv))
        raise Exception(message)
    hawk = Hawk(redash_id=argv[1], time_column=argv[2], value_column=argv[3], value_type='number')
    res = hawk.add()
    print(json.dumps(res))


if __name__ == "__main__":
    """"""
    main(sys.argv)