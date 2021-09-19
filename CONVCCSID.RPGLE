       ctl-opt dftactgrp(*no) bnddir('WEBSRVBND');
       //------------------------------------------------------------------- //
       //Author      : Adarsh                                                //
       //Date        : 19/9/2021                                             //
       //Description : Conversion of data between different CCSIDs           //
       //                                                                    //
       //------------------------------------------------------------------- //
       //prototype declarations...
       dcl-pr ConvertData       extpgm('CONVCCSID');
              InVal             char(500);
              fromccsid         char(4)  options(*nopass);
              toccsid           char(4)  options(*nopass);
              extUsId           char(10) options(*nopass);
              extPwd            char(10) options(*nopass);
              errFlag           char(1)  options(*nopass);
       end-pr;

       dcl-pi ConvertData;
              InVal             char(500);
              fromccsid         char(4)  options(*nopass);
              toccsid           char(4)  options(*nopass);
              extUsId           char(10) options(*nopass);
              extPwd            char(10) options(*nopass);
              errFlag           char(1)  options(*nopass);
       end-pi;

       //Open conversion description
       dcl-pr QtqIconvOpen      char(52) extproc('QtqIconvOpen');
              *n                pointer value;
              *n                pointer value;
       end-pr;

       //Convert Data
       dcl-pr iconv             bindec(4) extproc('iconv');
              ConvDesc          char(52) value;
              ptrtoinpBuffer    pointer value;
              ptrtoinpByteLeft  pointer value;
              ptrtooutBuffer    pointer value;
              ptrtooutByteLeft  pointer value;
       end-pr;

       //Close conversion description
       dcl-pr closeConv         bindec(4) extproc('iconv_close');
              ConvDesc          char(52) value;
       end-pr;

     d/copy QSYSINC/QRPGLESRC,QTQICONV

       //Standalone Variables
       dcl-s  Val               char(500);
       dcl-s  sepPos            zoned(3);
       dcl-s  endPos            zoned(3);
       dcl-s  UserId            char(10);
       dcl-s  passwd            char(10);

       dcl-s  InBufferPtr       pointer;
       dcl-s  OutBufferPtr      pointer;
       dcl-s  InByteLeft        bindec(4);
       dcl-s  OutByteLeft       bindec(4);

       dcl-s  ptrtoInBufferPtr  pointer;

       dcl-s rc                 bindec(4);


       //DataStructures
       dcl-ds fromCode          likeds(QTQCODE) inz;
       dcl-ds toCode            likeds(QTQCODE) inz;

       dcl-ds ConvDescriptor;
              rtnVal            int(10);
              rtn_;
              rtnArr            int(10) dim(12) overlay(rtn_);
       end-ds;


       //Main Starts...
       *inlr = *on;

       //set conversion from/to ccsid
       fromcode.QTQCCSID = 1208;
       tocode.QTQCCSID = 37;
       if %addr(fromccsid) <> *null;
         fromcode.QTQCCSID = %dec(%trim(fromccsid):4:0);
       endif;
       if %addr(toccsid) <> *null;
         tocode.QTQCCSID = %dec(%trim(toccsid):4:0);
       endif;

       //set error description to defaults
       fromcode.QTQERVED02 = *allx'00';
       tocode.QTQERVED02 = *allx'00';

       //Open conversion descriptor
       ConvDescriptor = QtqIconvOpen( %addr(toCode) : %addr(fromCode) );

       if rtnVal = -1;
         errFlag = 'Y';
         exsr endprocess;
       endif;

       //set value to be converted
       Val = inVal;
       InBufferPtr  = %addr(Val);
       InByteLeft   = %len(%trimr(Val));
       OutByteLeft  = %size(Val);

       ptrtoInBufferPtr = %addr(InBufferPtr);


       //Process Conversion from/to ccsid
       rc = iconv( ConvDescriptor         :
                   ptrtoInBufferPtr       :
                   %addr(InByteLeft)      :
                   ptrtoInBufferPtr       :
                   %addr(outByteLeft)       );

       //extract userID and password from decoded raw data from basic Auth
       sepPos = %scan('@':val:1);
       extUsId= %subst(val:1:sepPos-1);
       endpos = %scan('@':val:sepPos+1);
       extPwd = %subst(val:sepPos+1:endpos-sepPos-1);
       errFlag = 'N';

       exsr endProcess;

       //Main Ends...

       begsr endProcess;
       rc = closeConv( ConvDescriptor );
       return;
       endsr;
