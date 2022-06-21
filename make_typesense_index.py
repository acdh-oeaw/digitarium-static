import glob
import os
import ciso8601
import time

from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_cfts_pyutils import CFTS_COLLECTION
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm


files = glob.glob('./data/editions/*.xml')

try:
    client.collections['digitarium'].delete()
except ObjectNotFound:
    pass

current_schema = {
    'name': 'digitarium',
    'fields': [
        {
            'name': 'id',
            'type': 'string'
        },
        {
            'name': 'rec_id',
            'type': 'string'
        },
        {
            'name': 'title',
            'type': 'string'
        },
        {
            'name': 'full_text',
            'type': 'string'
        },
        {
            'name': 'date',
            'type': 'int64',
            'optional': True,
            'facet': True,
        },
        {
            'name': 'year',
            'type': 'int32',
            'optional': True,
            'facet': True,
        },
    ]
}

client.collections.create(current_schema)

records = []
cfts_records = []
for x in tqdm(files, total=len(files)):
    record = {}
    cfts_record = {
        'project': 'digitarium',
    }
    doc = TeiReader(x)
    body = doc.any_xpath('.//tei:body')[0]
    record['id'] = os.path.split(x)[-1].replace('.xml', '')
    cfts_record['id'] = record['id']
    record['rec_id'] = os.path.split(x)[-1]
    cfts_record['rec_id'] = record['rec_id']
    record['title'] = " ".join(" ".join(doc.any_xpath('.//tei:titleStmt/tei:title[1]//text()')).split())
    cfts_record['title'] = record['title']
    head, tail = os.path.split(x)
    date_str = tail.replace('ed__', '').replace('.xml', '')
    try:
        record['year'] = int(date_str[:4])
        cfts_record['year'] = record['year']
    except ValueError:
        pass
    try:
        ts = ciso8601.parse_datetime(date_str)
    except ValueError:
        ts = ciso8601.parse_datetime('1000-01-01')

    record['date'] = int(time.mktime(ts.timetuple()))
    cfts_record['date'] = record['date']
    record['full_text'] = " ".join(''.join(body.itertext()).split())
    cfts_record['full_text'] = record['full_text']
    records.append(record)
    cfts_records.append(cfts_record)

make_index = client.collections['digitarium'].documents.import_(records)
print('done with indexing')
print(make_index)

make_index = CFTS_COLLECTION.documents.import_(cfts_records)
print('done with central indexing')