For Creating IBM i as WebService Client, so as to process HTTP requests, listed below is the information
1. From HTTPAdmin create HTTP server. Document - WebServ in IBM i.docx
2. Modify the configuration for the HTTP server created. Document - WebServ in IBM i.docx
3.Write program to handle the HTTP requests:
  (a) PRCHTTP: to get data from environment variables
  (b) CONVCCSID: convert the UTF encoding of basic Auth raw data into EBCDIC and extract Userid and password
  (c) VALUSPWD; Validate the userId and Password for the user in IBM i.