import pandas as pd


start_date = '2014-01-01'
end_date = '2024-12-31'

date_range = pd.date_range(start=start_date,end=end_date)

date_dimension = pd.DataFrame(date_range,columns=['Date'])

date_dimension['DayofWeek']=date_dimension['Date'].dt.dayofweek
date_dimension['Month']=date_dimension['Date'].dt.month
date_dimension['Quarter']=date_dimension['Date'].dt.quarter
date_dimension['Year']=date_dimension['Date'].dt.year
date_dimension['Isweekend']=date_dimension['DayofWeek'].isin([5,6])
date_dimension['DateID']=date_dimension['Date'].dt.strftime('%Y%m%d').astype(int)

cols = ['DateID'] + [col for col in date_dimension.columns if col != 'DateID']
date_dimension=date_dimension[cols]

date_dimension.to_csv('DimDate.csv', index=False)