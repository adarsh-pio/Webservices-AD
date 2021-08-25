       ctl-opt option(*srcstmt) dftactgrp(*no) actgrp('HTTPREQ');

       dcl-s rspmsg          char(9999) inz;
       dcl-s rsphdr          char(2048) inz;
       dcl-ds users_ds;
              filler1       char(5)  inz('"id":');
              idval         char(10) inz;
              filler2       char(8)  inz(',"name":');
              nameval       char(50) inz;
              filler3       char(9)  inz(',"email":');
              emailval      char(80) inz;
              filler4       char(10) inz(',"gender":');
              genderval     char(10)  inz;
              filler5       char(10) inz(',"status":');
              statusval     char(10) inz;
       end-ds;
       dcl-ds body_ds;
              filla         char(1)  inz('{');
              users_        char(350);
              fillb         char(1)  inz('}');
       end-ds;

       dcl-ds rspcode;
              filler_a      char(26);
              responsecode  char(3);
              filler_b      char(2);
       end-ds;

       dcl-s extract        char(50);
       dcl-s startpos       zoned(4);
       dcl-s endpos         zoned(4);
       dcl-c search         const('responseCode');
       dcl-s newid          char(10);
       dcl-s cd             int(10);
       dcl-s text           char(100) inz;
       dcl-s wkUrl          char(200) inz;
       dcl-c Url            const('https://gorest.co.in/public/v1/users');
       dcl-s req            char(6)   inz;
       dcl-s body           char(5000) inz;
       dcl-s head           char(2048) inz;

       dcl-s wkId           char(10) inz;
       dcl-s wkName         char(50) inz;
       dcl-s wkemail        char(80) inz;
       dcl-s wkGender       char(10) inz;
       dcl-s wkStatus       char(10) inz;

       //set compiler options...

       exec sql set option commit = *none,
                           closqlcsr = *endmod,
                           monitor = *system;


       //Main Starts...

       exec sql CALL QCMDEXC('CHGJOB CCSID(37)');

       head = '<httpHeader><header name="Content-Type" value=' +
              '"application/json"></header>' +
              '<header name="Authorization" value=' +
              '"Bearer 84b09fbbc01f9a4d0141b70496c503795d8a64a5' +
              'ad8730bc20c0deaa846c4c17"></header></httpHeader>';

       //Implementation of HTTP POST method...
       wkId     = '1133';
       wkName   = 'Adarsh Kumar';
       wkEmail  = 'email@domain.in';
       wkgender = 'Male';
       wkstatus = 'Active';

       idval    = %trim(wkId);
       nameval  = '"' + %trim(wkName) + '"';
       emailval = '"' + %trim(wkEmail) + '"';
       genderval= '"' + %trim(wkGender) + '"';
       statusval= '"' + %trim(wkStatus) + '"';

       users_ = users_ds;
       body   = body_ds;

       //-----------HTTP POST-----------
       req = 'POST';

       exec sql select cast(RESPONSEMSG as character(9999)),
                       cast(RESPONSEHTTPHEADER as character(9999))
                into   :rspmsg, :rsphdr
                from table(SYSTOOLS.HTTPPOSTCLOBVERBOSE( trim(:Url),
                                                         trim(:head),
                                                         trim(:body)));
       exec sql get diagnostics condition 1 :text = MESSAGE_TEXT,
                                            :cd = DB2_RETURNED_SQLCODE;
       handlerr();



       //Implementation of HTTP GET method...

       wkUrl = %trim(Url) + '/' + %trim(newId);

       //-----------HTTP GET------------
       req = 'GET';

       exec sql select cast(RESPONSEMSG as character(9999)),
                       cast(RESPONSEHTTPHEADER as character(9999))
                into   :rspmsg, :rsphdr
                from table(SYSTOOLS.HTTPGETCLOBVERBOSE( trim(:wkUrl),
                                                        trim(:head)));

       exec sql get diagnostics condition 1 :text = MESSAGE_TEXT,
                                            :cd = DB2_RETURNED_SQLCODE;
       handlerr();


       //Implementation of HTTP PUT method...

       statusval= '"' + 'InActive' + '"';

       users_ = users_ds;
       body   = body_ds;
       wkUrl = %trim(Url) + '/' + %trim(newId);

       //-----------HTTP PUT------------
       req = 'PUT';

       exec sql select cast(RESPONSEMSG as character(9999)),
                       cast(RESPONSEHTTPHEADER as character(9999))
                into   :rspmsg, :rsphdr
                from table(SYSTOOLS.HTTPPUTCLOBVERBOSE( trim(:wkUrl),
                                                        trim(:head),
                                                        trim(:body)));
       exec sql get diagnostics condition 1 :text = MESSAGE_TEXT,
                                            :cd = DB2_RETURNED_SQLCODE;
       handlerr();


       //Implementation of HTTP DELETE method...

       wkUrl = %trim(Url) + '/' + %trim(newId);

       //-----------HTTP DELETE---------
       req = 'DELETE';

       exec sql select cast(RESPONSEMSG as character(9999)),
                       cast(RESPONSEHTTPHEADER as character(9999))
                into   :rspmsg, :rsphdr
                from table(SYSTOOLS.HTTPDELETECLOBVERBOSE( trim(:wkUrl),
                                                           trim(:head)));

       exec sql get diagnostics condition 1 :text = MESSAGE_TEXT,
                                            :cd = DB2_RETURNED_SQLCODE;
       handlerr();


       *inlr = *on;

       //Main Ends...

       //-----------------------------------------------------------------------

       dcl-proc handlerr;
       if rspmsg  <> *blanks;

       exec sql select r.id_, r.name_, r.email_, r.gender_, r.status_
                into :wkId, :wkName, :wkEmail, :wkGender, :wkStatus
                from (values(:rspMsg)) as table(dta),
       JSON_TABLE(table.dta, '$'
         columns(id_ char(10) path '$.data.id',
                 name_ char(50) path '$.data.name',
                 email_ char(80) path '$.data.email',
                 gender_ char(10) path '$.data.gender',
                 status_ char(10) path '$.data.status')) as r;
         if sqlcode = 0;
           idval    = %trim(wkId);
           newid    = %trim(wkId);
           nameval  = '"' + %trim(wkName) + '"';
           emailval = '"' + %trim(wkEmail) + '"';
           genderval= '"' + %trim(wkGender) + '"';
           statusval= '"' + %trim(wkStatus) + '"';

           users_ = users_ds;
           body   = body_ds;
         endif;
       endif;

       if rsphdr <> *blanks;
         startpos = %scan(search:rsphdr);
         startpos = %scanr('<':rsphdr:1:startpos);
         endpos = %scan('>':rsphdr:startpos);
         extract = %subst(rsphdr:startpos:endpos - startpos + 1);
         rspcode = extract;

       select;
       when req = 'POST' and responsecode = '201';
         dsply 'POST successful';
       when req = 'GET' and responsecode = '200';
         dsply 'GET successful';
       when req = 'PUT' and responsecode = '200';
         dsply 'PUT successful';
       when req = 'DELETE' and responsecode = '204';
         dsply 'DELETE successful';
       other;
         if responsecode = '400';
           dsply 'Bad Request';
         elseif responsecode = '401';
           dsply 'Authentication Failed';
         elseif responsecode = '404';
           dsply 'Request not found';
         elseif responsecode = '500';
           dsply 'Internal Server Error';
         endif;
       endsl;
       endif;
       end-proc;

       //-----------------------------------------------------------------------
