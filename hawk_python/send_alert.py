import json
import sys
from datetime import datetime

from queryBL.hawk import Hawk
from queryBL import send_mail


def main(argv):
    """
    :param argv: list of arguments -->  redash_id,
                                        time_column,
                                        value_column,
                                        value_type,
                                        time_unit,
                                        upper_bound,
                                        lower_bound,
                                        time_now,
                                        email_address
    """
    if len(argv) != 10:
        message = 'need to give 9 arguments(redash_id, time_column, value_column, value_type, time_unit, ' \
                  'upper_bound, lower_bound, time_now, email_address), given ' + str(len(argv) - 1)
        raise Exception(message)
    hawk = Hawk(redash_id=argv[1], time_column=argv[2], value_column=argv[3], value_type=argv[4])
    if argv[5] == 'hourly':
        time = datetime.strptime(argv[8], '%Y-%m-%d %H:%M:%S').replace(minute=0, second=0)
    else:
        time = datetime.strptime(argv[8], '%Y-%m-%d %H:%M:%S').date()
    ucl = float(argv[6])
    lcl = float(argv[7])
    res = hawk.is_outlier(time=str(time), ucl=ucl, lcl=lcl)
    send_to = argv[9]
    data = {}
    if res['is_alert']:
        if res['bound'] == ucl:
            data['above'] = True
        else:
            data['above'] = False
        data['value'] = res['value']
        send_alert_mail(send_to, res['redash_name'], time, data)
    res['is_upper'] = data['above']
    print(json.dumps(res))


def send_alert_mail(send_to, metrics_name, time, data, files='', cc_to='', bcc_to=''):
    """

    :param time: datetime alert
    :param send_to: string email address user
    :param metrics_name: string redash name
    :param data: dictionary alert value detail
    :param files: string url attachments
    :param cc_to: string email address cc user
    :param bcc_to: string email address bcc user
    """
    subject = metrics_name + " Alert"
    text = "The metrics value on " + str(time) + " is "
    if data["above"]:
        text = text + "increasing significantly ("
    else:
        text = text + "decreasing significantly ("
    text = text + str(data["value"]) + "). Please check the metrics to find the root cause."
    print(text)
    send_mail(send_to, subject, text, files, cc_to, bcc_to)


if __name__ == "__main__":
    main(sys.argv)