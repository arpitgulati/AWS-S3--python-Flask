#!/usr/bin/python 

import json
import os
import subprocess
import time
from flask import Flask, render_template,request,flash
from flask_uploads import UploadSet, configure_uploads, IMAGES, patch_request_class
from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileRequired, FileAllowed 
from wtforms import SubmitField
import boto3
from botocore.client import Config


app = Flask(__name__)
app.config['SECRET_KEY'] = 'I have a dream'
app.config['UPLOADED_PHOTOS_DEST'] = 'path/upload_image'

photos1 = UploadSet('photos', IMAGES)
photos2 = UploadSet('photos', IMAGES)
configure_uploads(app, photos1)
configure_uploads(app, photos2)
patch_request_class(app)  # set maximum file size, default is 16MB


class UploadForm(FlaskForm):
	photo1 = FileField(validators=[FileAllowed(photos1, u'Image only!'), FileRequired(u'File was empty!')])
	submit1 = SubmitField(u'Upload')
class Upload_validateForm(FlaskForm):
        photo2 = FileField(validators=[FileAllowed(photos2, u'Image only!'), FileRequired(u'File was empty!')])
        submit2 = SubmitField(u'Upload')
	
@app.route('/', methods=['GET', 'POST'])
def upload_file():
	form1 = UploadForm()
	form2 = Upload_validateForm()
	if form1.validate_on_submit():
		for i in request.files.getlist('photo1') :
			filename = photos1.save(i)
	
		ACCESS_KEY_ID = 'XXXXXXXXX'
		ACCESS_SECRET_KEY = 'XXXXXXXXXXXX'
		BUCKET_NAME = 'jdomnicontent'
		path='path/upload_image'
		url1=[]
		for i in os.listdir(path):
			t=time.localtime()
        		data = open((os.path.join(path,i)),'rb')
        		lis=i.split(".")
			key1=".".join(lis[:-1])+"_"+time.strftime('%y%m%d%H%M', t)+"."+lis[-1]
			s3 = boto3.resource(
    			's3',
    			aws_access_key_id=ACCESS_KEY_ID,
    			aws_secret_access_key=ACCESS_SECRET_KEY,
    			config=Config(signature_version='s3v4')
			)
			response=s3.Bucket(BUCKET_NAME).put_object(Key='AWS Bucket/'+key1, Body=data,ContentType='image/'+lis[-1])		
			url1.append("AWS URL"+key1)
		        subprocess.call(['mv', path+'/'+i, 'path/upload_image.bk'])
		
                return render_template("link.html",url1=url1)
	
	elif form2.validate_on_submit():
		for i in request.files.getlist('photo2') :
			filename = photos2.save(i)

		ACCESS_KEY_ID = 'XXXXXXXXXXXXXXXXXXXX'
                ACCESS_SECRET_KEY = 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
                BUCKET_NAME = 'bucket name'
                path='path/upload_image'
                url1=[]
		a=0
		c=[]
		for i in os.listdir(path):
				
			data = open((os.path.join(path,i)),'rb')
			lis=i.split(".")
			s3 = boto3.resource(
                        's3',
                        aws_access_key_id=ACCESS_KEY_ID,
                        aws_secret_access_key=ACCESS_SECRET_KEY,
                        config=Config(signature_version='s3v4')
                        )
			s3.Bucket(BUCKET_NAME).put_object(Key='jdomni_email/'+i, Body=data,ContentType='image/'+lis[-1])
			url1.append("AWS URL/"+i)
                        subprocess.call(['mv', path+'/'+i, '/home/justdial/upload_image.bk'])
			dic={'objects':[url1[a]]}
			dic1=json.dumps(dic)
			print dic1
			####Clear akamai Cache
			response=subprocess.Popen(["curl", 
			"https://api.ccu.akamai.com/ccu/v2/queues/default", "-H","Content-Type:application/json","-d",
			dic1 ,"-u", "cacheapi@company name:password"],stdout=subprocess.PIPE)
			(out,err)=response.communicate()
#			print "=========================="

			b=out.split(",")
			d=int((b[0].split(':')[1]))
			d=d/60
			c.append(d) 
			a=a+1
		
		temp=dict(zip(url1,c))
		return render_template("link2.html",temp=temp)
			
			 
	else:
		file_url = None

	return render_template('index.html', form1=form1,form2=form2)

app.run(host="172.29.132.24",port=5000,debug=False)
