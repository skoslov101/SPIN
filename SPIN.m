clear

expDirectory = pwd;
dataDirectory = [expDirectory '\Data'];

cd(expDirectory);
%New MATLAB2013 compatable create randomization code.
matlabversion  = version;
matlabversion = str2num(matlabversion(1:3));
if matlabversion >= 7.7
    rand('twister',sum(100*clock));
else
    rand('twister',sum(100*clock));
%     s = RandStream('swb2712','Seed',sum(100*clock));
%     RandStream.setGlobalStream(s);
% else
%     rand('state',sum(100*clock))
end

% Enter subject data
datainputflag = 0;
while datainputflag ~= 1
    initflag = 0;
    while initflag ~= 1
        prompt = {'Subject Number', 'Subject Initials', 'TrialNumbers'};
        name = ['Welcome to ' mfilename];
        defAns = {'1','test','16'};
        options.Resize = 'on';
        options.WindowStyle = 'normal';
        options.Interpreter = 'tex';
        info = inputdlg(prompt,name,1,defAns,options);
        if isempty(info)
            return
        end
        pid = info{1};
        pinitT = info{2};
        trialNum = info{3};


        pinitT = str2double(pinitT);
        if isnan(pinitT)
            pinit = info{3};
            initCH = 1;
            initCHerr = '';
        else
            initCH = 0;
            initCHerr = 'Subject Initials needs to be entered as letters';
        end

        pid = str2double(pid);
        if isnan(pid)
            subCH = 0;
            subCHerr = 'Subject Number needs to be entered as (a) number(s)';
        else
            subCHerr = '';
            subCH = 1;
        end
%         
%         walkinID = str2double(walkinID);
%         if isnan(walkinID)
%             walkCH = 0;
%             walkCHerr = 'WalkinID needs to be entered as (a) number(s)';
%         else
%             walkCHerr = '';
%             walkCH = 1;
%         end
        
        trialNum = str2double(trialNum);
        if isnan(trialNum) || trialNum>64 || trialNum<=0
            condCH = 0;
            condCHerr = 'Trial Number needs to be an integer 1-64';
        else
            condCHerr = '';
            condCH = 1;
        end

        if initCH + subCH + condCH == 3
            if strcmpi(pinit,'debug')
                options.Default='No';
                debugquest = 'You have initialized debug mode, do you want to continue in debug mode?';
                orlydebug = questdlg(debugquest,'Debug Mode?','Yes','No',options);
                if strcmpi(orlydebug,'Yes')
                    initflag = 1;
                end
                debug = 1;
                randresp = 1;
                speedup = 100;
            else
                debug = 0;
                randresp = 0;
                speedup = 1;
                initflag = 1;
            end
        else
            errorText = {initCHerr, subCHerr, condCHerr};
            uiwait(errordlg(errorText, 'Error!'));
        end
    end


    options.Default='No';
    checkinfo = {'Is the follow ing information correct',...
        '',...
        [pinit ' = Subject`s Initials'],...
        [num2str(pid)  ' = Subject Number'],...
        [num2str(trialNum) ' = Trials Number'],...
        };
    check = questdlg(checkinfo,'Is this info correct?','Yes','No',options);
    if strcmpi(check,'Yes')
        datainputflag = 1;
    end
end
% 
% switch condNum
%     case 1
%         SPIN_prac(debug); %Two practice trials
%     case 2
%         data = SPIN1_3(debug,trialNum); %Day 1: 600 trials of acquisition
% end

data = SPIN1_3(debug,trialNum); %Day 1: 600 trials of acquisition

filename = ['SPIN_' num2str(pid) '_' pinit '_' num2str(trialNum) '.mat'];

cd Data

% Write data (.mat format)
% Note: data can later be written to .xls if so desired, but limited
% excel capability in some computer stations makes .mat the most consistent
% method of data storage
save(filename,'data');

cd(expDirectory)

Screen('CloseAll') % Close all