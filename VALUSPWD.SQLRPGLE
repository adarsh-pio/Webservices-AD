       ctl-opt option(*srcstmt)  Alwnull(*UsrCtl);
       ctl-opt dftactgrp(*no) actgrp(*stgmdl) stgmdl(*teraspace);
       //------------------------------------------------------------------- //
       //Author      : Adarsh                                                //
       //Date        : 19/9/2021                                             //
       //Description : Program to validate the encoded data for basic auth   //
       //              from HTTP request                                     //
       //------------------------------------------------------------------- //
       //Prototype declaration
       dcl-pr ValidateUserPass   extpgm('VALUSPWD');
             userData            char(500);
             fromccsid           char(4);
             toccsid             char(4);
             authUser            char(10);
             err                 char(1);
       end-pr;
       dcl-pi ValidateUserPass;
             userData            char(500);
             fromccsid           char(4);
             toccsid             char(4);
             authUser            char(10);
             err                 char(1);
       end-pi;

       dcl-pr UserPassIfExists   extpgm('QSYGETPH');
             userId              char(10);
             pass                char(10);
             prfHandle           char(12);
             errCode             likeds(ERRC0100);
             passLen             bindec(4);
             ccsid               bindec(4);
       end-pr;

       dcl-pr ConvertData       extpgm('CONVCCSID');
              InVal             char(500);
              fromccsid         char(4)  options(*nopass);
              toccsid           char(4)  options(*nopass);
              extUsId           char(10) options(*nopass);
              extPwd            char(10) options(*nopass);
              errFlag           char(1)  options(*nopass);
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
       dcl-s prfHandle           char(12);
       dcl-s wkUser              char(10);
       dcl-s wkPass              char(10);
       dcl-s rawData             char(500);
       dcl-s rawData_EBC         varchar(1208);
       dcl-s rawData_ASC         varchar(1208);
       dcl-s colPos              zoned(2) inz;
       dcl-s txt                 char(256);
       dcl-s passLen             bindec(4);
       dcl-s passccsid           bindec(4);

       //Set compiler directive
       exec sql set option commit = *none, closqlcsr = *endmod,
                           monitor = *system;

       //Main Starts
       exec sql Set :RawData = SYSTOOLS.BASE64decode(
                               CAST(trim(:userData) AS character(500)
                               CCSID 1208));
       exec sql get diagnostics condition 1 :txt = message_text;

       ConvertData(rawData:fromccsid:toccsid:wkUser:wkPass:err);
       if err = 'N';
         passLen = %len(wkPass);
         passccsid = %dec(%trim(toccsid):4:0);
         UserPassIfExists(wkUser:wkPass:prfHandle:ERRC0100:passLen:passccsid);
         authUser = wkUser;
       endif;


       *inlr = *on;

       //Main Ends
