from mrjob.job import MRJob
from mrjob.step import MRStep
from datetime import datetime


class AverageAgeCalculator(MRJob):

    def mapper(self, _, line):
        try:
            fields = line.split(',')
            if fields[0] == 'ROW_ID':
                return

            dob_str = fields[3].strip() 
            dob = datetime.strptime(dob_str, "%m/%d/%Y %H:%M")

            dod_str = fields[4].strip()  
            if dod_str:
                dod = datetime.strptime(dod_str, "%m/%d/%Y %H:%M")
                age = (dod - dob).days / 365.2425
                yield "average_age", age

        except (ValueError, IndexError):
            pass

    def reducer(self, key, values):
        values_list = list(values)
        if values_list:  # Avoid ZeroDivisionError if no valid ages
            avg_age = sum(values_list) / len(values_list)
            yield key, avg_age


if __name__ == '__main__':
    AverageAgeCalculator.run()
