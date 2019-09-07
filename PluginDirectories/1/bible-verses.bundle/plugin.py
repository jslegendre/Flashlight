import requests
import scriptures
import re
import json

def results(fields, original_query):
	
  
  	if '~reference' in fields:
	 	reference = fields['~reference']
 	else:
 		reference = ''

 	if '~translation' in fields:
 		translation = fields['~translation']
 	else:
 		translation = 'kjv'

 	reference = re.sub(r'[\s|\.](.+?)\.',r' \1:',reference)
 	title = "Find verse text ... {0}".format(reference)

 	# using bible-api.com
 	# example search https://bible-api.com/john 3:16

	special_message = None
	verse = ''
	#try:
	r = get_text(reference, translation)
	
 	if 'error' in r:
 		if r['error'] == 'translation not found':
			r = get_text(reference, 'kjv')	
			special_message = translation + ' translation not found. Defaulted to KVJ.'

		elif r['error'] == 'not found':
			verse = 'Reference not found. Please try again.'
			r['reference'] = reference
			special_message = ' '

		else:
			verse = r['error']
			r['reference'] = reference
			special_message = " "
	else:
		for item in r['verses']:
			verse+=(item['text'].replace('\n',' '))


	html = "<div style='font-family: sans-serif; padding: 1em'><p>{0}</p><p>{1}</p><p><small>{2}<br><a href='https://bible-api.com'>https://bible-api.com</a></small></p></div>".format(verse, r['reference'],special_message or r['translation_name'])
	title = verse[:20] + '... ' + r['reference']

	#except:
#		html = "<div style='font-family: sans-serif; padding: 1em'>searching ... {0}</div>".format(reference)
	
 	return {
    "title": title,
    "run_args": [reference],
	"html": html
 	}

def run(reference):
    print("nothing running..")
    #import os
    #os.system('say "{0}"'.format(reference))


def get_text(reference, translation):

	return json.loads(requests.get('https://bible-api.com/' + reference + '?translation='+ translation).text)
