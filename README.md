# postgre-gis
🌏 PostgreSQL + PostGIS + Docker 空间计算！

# 写入 AOI
```python
import pandas as pd
import psycopg2
from openpyxl import Workbook
import re


wb = Workbook()
ac = wb.active
line = ['name', 'data', 'origin']
ac.append(line)
# 是否出现错误
error_flag = 0
conn = psycopg2.connect(database="space", user="postgres", password="123123", host="localhost")
cur = conn.cursor()
aoi_file = pd.read_excel("./aoi.xlsx", engine='openpyxl')
line_num = aoi_file.shape[0]

# 清空表
clean_sql = "DELETE FROM aoi WHERE 1=1"
cur.execute(clean_sql)
conn.commit()

for i in range(0, line_num):
    get_name = aoi_file.iat[i, 0]
    '''
    {"type":
        "Polygon",
        "coordinates": [[[
            121.342079,31.417835],[121.342105,31.417812],[121.34214,31.417802],
            [121.342177,31.4178],[121.343274,31.417851],[121.343306,31.41786],[121.343333,31.417879],
            [121.343354,31.417911],[121.343364,31.417945],[121.343424,31.419663],[121.343423,31.419707],
            [121.343414,31.419746],[121.343384,31.419832],[121.343351,31.419903],[121.343318,31.419927],
            [121.343276,31.419931],[121.341537,31.419355],[121.341508,31.419332],[121.341486,31.419301],
            [121.341486,31.419268],[121.341496,31.41923],[121.342056,31.417871],[121.342079,31.417835
        ]]]}
    '''
    get_geom = aoi_file.iat[i, 1]
    origin_geom = get_geom
    get_geom = re.sub(' ', '', str(get_geom))
    get_geom = re.sub('MultiPolygon', 'Polygon', str(get_geom))
    get_geom = re.sub("\[\[\[\[", '[[[', str(get_geom))
    get_geom = re.sub("\]\]\]\]", ']]]', str(get_geom))
    get_geom = re.sub('\{', ' ', str(get_geom))
    get_geom = re.sub('\}', ' ', str(get_geom))
    get_geom = re.sub('"type":"Polygon"', "", str(get_geom))
    get_geom = re.sub('"coordinates":\[\[\[', '', str(get_geom))
    get_geom = re.sub('\]\]\]', '', str(get_geom))
    get_geom = re.sub(' ', '', str(get_geom))
    get_geom = re.sub(',', ' ', str(get_geom))
    get_geom = re.sub('\] \[', ',', str(get_geom))
    print(get_name)
    # INSERT INTO geometries VALUES(
    # 'B0FFG1YVX3',
    # 'MULTIPOLYGON(((120.394543 36.113915,120.39454 36.113898,120.394539 36.113869,120.394548
    # 36.113844,120.394586 36.113812,120.396095 36.11299,120.396118 36.112986,120.396133 36.112988
    # ,120.39615 36.112998,120.39712 36.114184,120.39713 36.114219,120.397129 36.114262,120.397118 36.114297
    # ,120.397101 36.114325,120.397075 36.114359,120.397043 36.114389,120.396994 36.114425,120.39584 36.115065,
    # 120.395818 36.11507,120.395793 36.115071,120.395762 36.115068,120.395719 36.115058,120.395686 36.115043,
    # 120.395661 36.115029,120.394543 36.113915)))');
    sql = "INSERT INTO aoi VALUES('" + str(get_name) + "'," + \
        "'MULTIPOLYGON(((" + str(get_geom) + ")))');"
    try:
        cur.execute(sql)
        conn.commit()
    except Exception as e:
        error_flag = 1
        conn.rollback()
        line = [str(get_name), str(get_geom), str(origin_geom)]
        ac.append(line)
        print(e)
        print(sql)
conn.close()

# 0 no error | 1 have error
if error_flag == 1:
    try:
        wb.save("./error_data.xlsx")
    except PermissionError:
        wb.save("./new_error_data.xlsx")
```

# 写入 POI
```python
import pandas as pd
import psycopg2
import re

conn = psycopg2.connect(database="space", user="postgres", password="123123", host="localhost")
cur = conn.cursor()
poi_file = pd.read_excel("./poi.xlsx", engine='openpyxl')
line_num = poi_file.shape[0]

# 清空表
clean_sql = "DELETE FROM poi WHERE 1=1"
cur.execute(clean_sql)
conn.commit()

for i in range(0, line_num):
    get_name = poi_file.iat[i, 0]
    '''
    121.56042,31.20459
    '''
    get_poi = poi_file.iat[i, 1]
    origin_poi = get_poi
    get_poi = re.sub(" ", "", str(get_poi))
    get_poi = re.sub("，", " ", str(get_poi))
    get_poi = re.sub(",", " ", str(get_poi))
    print(get_name)
    if str(get_name) == 'nan':
        continue
    # INSERT INTO geometries VALUES(
    # 'B0FFG1YVX3',
    # 'MULTIPOLYGON(((120.394543 36.113915,120.39454 36.113898,120.394539 36.113869,120.394548
    # 36.113844,120.394586 36.113812,120.396095 36.11299,120.396118 36.112986,120.396133 36.112988
    # ,120.39615 36.112998,120.39712 36.114184,120.39713 36.114219,120.397129 36.114262,120.397118 36.114297
    # ,120.397101 36.114325,120.397075 36.114359,120.397043 36.114389,120.396994 36.114425,120.39584 36.115065,
    # 120.395818 36.11507,120.395793 36.115071,120.395762 36.115068,120.395719 36.115058,120.395686 36.115043,
    # 120.395661 36.115029,120.394543 36.113915)))');
    sql = "INSERT INTO poi VALUES('" + str(get_name) + "'," + \
            "'POINT(" + str(get_poi) + ")');"
    try:
        cur.execute(sql)
    except Exception as e:
        print(e)
        print(f"sql => {sql}")
        print(f"get_name => {get_name} | get_poi => {get_poi}")
        exit(0)
conn.commit()
conn.close()

```
