import 'package:gsheets/gsheets.dart';
class SheetConfiguration {
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "welfare-attendance-388218",
  "private_key_id": "48373b4ba6cbf534980660d18f13ad70c3c527d6",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCYkE3p28fmc50r\nlRKxkWqVyVs3xXQAVwIAbTXvePAtLb33k5G9uKs4c05Eerar3A7GWbTV0zmnIZYF\nMblMGiOYoYHKD6LcKnFV+Gbl6arT0N/sG8XLqqTo89GS0hd0dqBkf00V9jZ3AbvM\nmqFh+jvo6oNzaPT07HMLam+FNdUc4IoV/dy9j4RfQLNDauuVFAV7YLY/MEMFmt8S\nLBzxhCbe2TnQuQ0s5HlFuwe1oiirAUS/IaAJ0NU/YZFAewn7O/SAHqv3nf5JIjzp\ngiNN57mcesBMuHNXC5P7KXLuekcJbsbrPCTJEQC4WxCzeXIvt/ZUr6dB/CtY1Scr\n1mFTDNHVAgMBAAECggEAAxHAJ4jO7EF+M37DygPBb7MF3UjhLRKTDTwlPiSiPF5z\nuHPlFjqNY0zakcEgRLPgLjhmzXh66/Rehss5zaCm/66cJFsNLT3DWvXs6Ao78Bf/\nMUpbv922hKNHH5uPcj3iuzLec6co8Fr+Er83qPd2VhjFvUAq0XSiWePxy23KVFLe\nMJaAy6WuZSUw1Vm2a55F9ZavwE9bKMAwwX9XBnR8zIoSeldMdkSKGjfMK526Xuig\nPLtPL5UvEYSxiqNUUGbkqMCrwuW6kQTXNlusWRJO4WA7RREoXSFfBTNEOeoqb9ji\nQXyyjpqBMkxuJxJ1v1jYBxbOnVbFzdfBWzroucOz/wKBgQDGueFBhLVdyNroKrED\nX4URucNlnOeMtvn5KgRAceP7AiUjRCrlZYGzAKw9EziYbmELIZZ5++l4KVFFTuX0\nRwtFXLN6+iDVqO4rGl1ZL95xkdI5lYmbmqzf/3wplTqOAy4WPHKIR6rWk3YOFKw1\n5jLzSI2lN+vi0dNu9peaFtlSDwKBgQDEiIl0pvIGMkqddgLb0NlM5w8ftM40AUjx\nOo7b29lmM7ZRTJ95UCvaN9/TlSHS53zDNJdMto6aZsiK+zfls5FEUnA8oGQeezvj\nXcbGrAi1UWhs1ZVGi5cTyYcl+e/zqIIaIwBbHLcSNByMquozS9Tu3iYkkknryyU2\nUVjN5mVx2wKBgQCIQI4HI/xODxa4M/0l+On920Xzd37y5cnCYmKD5RKQ2UmpQmW+\n3rfsiTuOrI0TRirXPPI1NNlAf+OvB4d20vcRWZvdZ333wFl7yBnUupNjfr2KqdKt\nk4GQG1WAFUcOc3O33z4P3kNt17ELunTQh8LLNyWW8B6VZ5P18rDC/4OFVQKBgHBd\nmCln4eyFCIAqnsvLBtKfMNhx6Yt2SJwTXOZ7NjrmyhCFfJBBtDDZzVENbP9GduCs\nyuyDW9kPdw1vQLBGEII9mAoxscxzrPP8A9BHP9tbJhdDrktdOA2KJYki83weFfSX\nmnZ9XnY78S7D8Y9OhfnkbW5vbXAw/5+ktt9SISINAoGAM3SZ169e/m2ShUiNvRol\ns67Ir3qJ3iEwFd781cUIwBK9609IPt6HpUkOgxEvK6o+I7uPAQYU/+wiDe4ye6aO\npYvy2d5IbhKD4iHbcTUyxhUNuaxToGWraKMRkHEAp8kugE7Z9BHz1ZQPFMosHt49\nYnDrB41HPdjS/HToZvDtQ8w=\n-----END PRIVATE KEY-----\n",
  "client_email": "attendancesheet@welfare-attendance-388218.iam.gserviceaccount.com",
  "client_id": "111800130765865744195",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/cert s",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/attendancesheet%40welfare-attendance-388218.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

  static get credentials => _credentials;
  static final sheet = GSheets(_credentials);
}
