#Pandas
import pandas as pd
import numpy as np
df = pd.read_csv(r'E:\01 Statistics and Analytics\00 Workspace\Projects\01Anaconda Projects\Election Project' +\
                            r'\for Python\ESDATA.csv')
StateFilled= df.States.fillna(method="ffill")
temp = [StateFilled, df.Religious_Communities,df.Total_Persons,
        df.Total_Male, df.Total_Female,df.Rural_Persons,
        df.Rural_Male,df.Rural_Female,df.Urban_Persons,df.Urban_Male,
        df.Urban_Female]
OutRec =pd.concat(temp, axis=1)
OutRec.to_csv(r'E:\01 Statistics and Analytics\00 Workspace\Projects\01Anaconda Projects\Election Project' +\
                  r'\for Python\Mod5.csv')
