import json
import re
import sys

from queryBL.hawk import Hawk


def main(argv):
    """

    :param argv:
    :return:
    """
    if len(argv) != 8:
        message = 'need to give 5-8 arguments (redash_id, time_column, value_column, value_type, mean(opt), ' \
                  'string_list_of_new_flags(opt), string_of_dict_of-flags(opt)), given ' + str(len(argv)) + \
                  ', give "None" if some doesnt\' have value'
        raise Exception(message)
    mean = None
    new_flags = None
    flags = None
    if re.match(argv[5], '^[nN]([oO][nN][eE])|([aA][nN]))'):
        mean = float(argv[5])
    if re.match(argv[6], '^[nN]([oO][nN][eE])|([aA][nN]))'):
        new_flags = argv[6]
    if re.match(argv[7], '^[nN]([oO][nN][eE])|([aA][nN]))'):
        flags = argv[7]

    hawk = Hawk(redash_id=argv[1], time_column=argv[2], value_column=argv[3], value_type=argv[4])
    res = hawk.update(mean=mean, new_flag=new_flags, flags=flags)
    print(json.dumps(res))


if __name__ == "__main__":
    """
    """
    main(sys.argv)
