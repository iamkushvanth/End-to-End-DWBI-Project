import pandas as pd
import random
import csv

num_rows = int(input( " Enter the number of rows that you want to generate in the csv file : "))



csv_file = input ( " Enter the name of the csv file : ")

# details of the excel file that has the lookup data , File Path and Name , Sheet Name and column names where the data is present 

excel_file_path_name = "C:/Users/2144ax/Downloads/End-to-End DWBI Project/LookupFile.xlsx"
excel_sheet_name_product = "Raw Product Names"
product_column_name  = "Product Name"
excel_sheet_name_category = "Product Categories"
category_column_name = "Category Name"




df = pd.read_excel(excel_file_path_name,sheet_name=excel_sheet_name_product)
df_cat = pd.read_excel(excel_file_path_name,sheet_name=excel_sheet_name_category)




with open(csv_file,mode='w',newline='') as file:
    writer=csv.writer(file)


 
    header=['ProductName','Category','Brand','UnitPrice']


 
    writer.writerow(header)


 
    for _ in range(num_rows):

        


        row = [
            df[product_column_name].sample(n=1).values[0],
            df_cat[category_column_name].sample(n=1).values[0],
            random.choice(['FakeLuxeAura','FakeUrbanGlow','FakeEtherealEdge','FakeVelvetVista','FakeZenithStyle']),
            random.randint(100,1000)
        ]




        writer.writerow(row)



print(" the process completed Successfully")