       ctl-opt option(*srcstmt) dftactgrp(*no) actgrp(*new) alwnull(*usrctl);
       ctl-opt BndDir( 'QC2LE' : 'ADARSH/WEBSRVBND' );
       //------------------------------------------------------------------- //
       //Author      : Adarsh                                                //
       //Date        : 19/9/2021                                             //
       //Description : Sample program to process http requests to IBM i      //
       //                                                                    //
       //------------------------------------------------------------------- //
       //Prototype declarations
       dcl-pr items     extpgm;
             itm#       char(20) options(*nopass);
       end-pr;
       dcl-pi items;
             itm#       char(20) options(*nopass);
       end-pi;

       dcl-pr ValidateUserPass   extpgm('VALUSPWD');
             userData            char(500);
             fromccsid           char(4);
             toccsid             char(4);
             AuthUser            char(10);
             err                 char(1);
       end-pr;

       dcl-pr getenv             extproc('QtmhGetEnv');
             rcvVar              char(5000);
             rcvLen              bindec(4);
             rspLen              bindec(4);
             reqVar              char(50);
             reqVarLen           bindec(4);
             errCd               likeds(ERRC0100);
       end-pr;

       dcl-pr writetoWeb         extproc('QtmhWrStout');
             DataVar             char(5000);
             DataVarLen          bindec(4);
             errCd               likeds(ERRC0100);
       end-pr;

       //DataStructures
       dcl-ds ERRC0100 inz;
              bytesProv          bindec(4);
              bytesAvail         bindec(4);
              excepID            char(7);
              res                char(1);
              excepDta           char(256);
       end-ds;

       //StandAlone Variables
       dcl-s rcvVar     char(5000);
       dcl-s rcvLen     bindec(4);
       dcl-s rspLen     bindec(4);
       dcl-s reqVar     char(50);
       dcl-s reqVarLen  bindec(4);
       dcl-s reqMethod  char(15);
       dcl-s url        char(200);
       dcl-s respData   char(5000);
       dcl-s respDataL  bindec(4);
       dcl-s authName   char(500);
       dcl-s crlf       char(2) inz(x'0d25');
       dcl-s fromccsid  char(4) inz('1208');
       dcl-s toccsid    char(4) inz('37');
       dcl-s errFlag    char(1) inz;
       dcl-s AuthUser   char(10);


       //Main Starts
       //Get request Method
       clear rcvVar;
       clear rcvLen;
       clear rspLen;
       reqVar = 'REQUEST_METHOD';
       reqVarLen = %len(%trim(reqVar));
       getenv(rcvVar:rcvLen:rspLen:reqVar:reqVarLen:ERRC0100);


       //Get requested URL
       clear rcvVar;
       clear rcvLen;
       clear rspLen;
       reqVar = 'REQUEST_URI';
       reqVarLen = %len(%trim(reqVar));
       getenv(rcvVar:rcvLen:rspLen:reqVar:reqVarLen:ERRC0100);

       //Write Header
       respdata = 'Content-Type: text/plain' + CRLF;
       respDataL = %len(%trim(respData));
       writeToWeb(respData:respDataL:ERRC0100);

       //Get Authorization Data
       clear rcvVar;
       clear rcvLen;
       clear rspLen;
       reqVar = 'HTTP_AUTHORIZATION';
       reqVarLen = %len(%trim(reqVar));
       getenv(rcvVar:rcvLen:rspLen:reqVar:reqVarLen:ERRC0100);
       authName = %trim(rcvVar);
       if authName <> *blanks;
         ValidateUserPass(authName:fromccsid:toccsid:AuthUser:errFlag);
       endif;


       *inlr = *on;
