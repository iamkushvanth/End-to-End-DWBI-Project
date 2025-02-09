import pandas as pd
import numpy as np
import os

DateID = '20240728'
directory = "C:/Users/2144ax/Downloads/End-to-End DWBI Project/Landing Directory"

for i in range(1,101):
    num_rows = np.random.randint(100,1000)

    data = {
    'DateID': [DateID]*num_rows,
    'ProductID': np.random.randint(1,1001,size=num_rows),
    'StoreID': [i]*num_rows,
    'CustomerID': np.random.randint(1,1001,size=num_rows),
    'QuantityOrdered': np.random.randint(1,21,size=num_rows),
    'OrderAmount': np.random.randint(100,1001,size=num_rows) }
    
    df = pd.DataFrame(data)

    discount_perc = np.random.uniform(0.02,0.15,size=num_rows)
    shipping_cost = np.random.uniform(0.05,0.15,size=num_rows)

    df['DiscountAmount'] = df['OrderAmount'] * discount_perc
    df['Shipping Cost'] = df['OrderAmount'] * shipping_cost
    df['TotalAmount'] = df['OrderAmount'] - (df['DiscountAmount']+df['Shipping Cost'])

    print(df)

    file_name = f'Store_{i}_{DateID}.csv'
    file_path = os.path.join(directory,file_name)

    if os.path.exists(file_path):
        os.remove(file_path)



    df.to_csv(file_path,index=False)
















