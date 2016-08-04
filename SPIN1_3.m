function [data] = SPIN1_3(debug, trialNum)
%% This is the the MATLAB version of the speech in noise task (SPIN)
% Created on 12/18/14 by Seth Koslov and Zilong Xie
% Formatted on 8/2/16 by Seth Koslov

%% Set up screen and all of that info
%Skip this stuff because it never works.
Screen('Preference', 'SkipSyncTests', 1)
Screen('Preference','VisualDebugLevel', 0)

%Set directories for easy access and naming
expDirectory = pwd;
dataDirectory = [expDirectory '/Data'];
soundDirectory = [expDirectory '/sounds'];

%Debug initialization or not.  Start up code(Unl6.m) decides this already.
if debug==1;speedup=1/100;else speedup=1;end % Speed up delays if in debug mode

% Specify color values
colors.white = [255 255 255];
% gray = [128 128 128];
colors.black = [0 0 0];

% Select the display screen on which to show our window:
screenid = max(Screen('Screens'));

% Open a window on display screen 'screenid'. We choose a 50% gray
% background by specifying a luminance level of 0.5:
% window = Screen(screenid, 'OpenWindow', BlackIndex(screenid), [100,200,900,800]);
window = Screen(screenid, 'OpenWindow', BlackIndex(screenid),[],[],[],[],10);

% Define center of screen
rect = Screen('Rect', window); %[0,0,1920,1080]
Xorigin = (rect(3)-rect(1))/2;
Yorigin = (rect(4)-rect(2))/2;
txtsize=18;

Screen(window,'TextFont','Verdana'); % Set text font
Screen(window,'FillRect', colors.black); % Fill background with backcolor (black)

%Load and randomize stimuli
[null,stims]=xlsread([expDirectory '/stimuliList.xlsx']);
expTrials=[Shuffle(1:16) Shuffle(17:32) Shuffle(33:40) Shuffle(41:64)];
perType=ceil(trialNum/4);

trialVar=[expTrials(1:perType) expTrials(17:16+perType) expTrials(33:32+perType) expTrials(41:40+perType)];
trialList=stims(trialVar,:);
% 
% for trI=1:length(trialVar)
%     if strcmpi(trialList{trI,3}(1),'s')==1
%         trialList{trI,5}=4;
%     else
%         trialList{trI,5}=str2double(trialList{trI,3}(1));
%     end
% end

% randVar = randperm(length(stims));
totalpoints=0;
trialN=0;
score_1t=0;
score_2t=0;
score_8t=0;
score_ssn=0;
possssn=0;
poss1t=0;
poss2t=0;
poss8t=0;
totPos=0;

%Instructions
instructions = ['Welcome to the Speech in Noise Challenge!',...
    '\n\n',...
    'For this challenge, you will be asked to interpret the speech that you hear \n',...
    'in different types of noise.',...
    '\n\n',...
    'How it works is you will see a cross on the middle of the screen. \n',...
    'That means to get ready for the next trial.',...
    '\n\n',...
    'Then you will start to hear noise.  About half a second after the noise starts, \n',...
    'the target sentence will begin.',...
    '\n\n',...
    'Your job is to report that target sentence as best that you can.',...
    'You need to wait until the sentence is done playing before you can type anything.',...
    '\n\n',...
    'Please press the spacebar to continue'];

    %display block instructions
% cenTex3(instructions,window,screenRect,black,white,18) % Print text centered
DrawFormattedText(window, instructions, 'center', 'center', colors.white);
Screen('Flip',window);
if debug~=1;getResp('space');end; % Wait for user to press 'space bar'; % Wait for user to press 'space bar'  
% if debug~=1;getResp_laptop('space');end;

%% Add in practice trial here.
% instructions = ['Here, we will show you an example stimulus.'

%% Start Experiment 
for i = 1:length(trialVar)
    trialN=trialN+1;
    %Display fixation cross
    DrawFormattedText(window, '+', 'center', 'center', colors.white);
    Screen('Flip',window);
%     cenTex3({'+'},window,screenRect,colors.black,white,32) % Display fixation cross
    
    %Get sound file information
    wavStr = stims{trialVar(i),1}; % Get .wav file name
    fileStr = [soundDirectory '/' wavStr]; % Define full directory call string
    corrResp = stims{trialVar(i),4};
   
    %Play the sound, pause experiment for duration of sound file
    [y,Fs]=audioread(fileStr); % Read .wav file
    stimSound=audioplayer(y,Fs); % convert to play
    play(stimSound);
    tic
    stimLength=length(y)/Fs;
    
    %Get information about the correct responses
    crFind=find(corrResp(:)==' ');
    
    if length(crFind)==2
        wordSwitch=1;
        keyword1=corrResp(1:crFind(1)-1);
        keyword2=corrResp(crFind(1)+1:crFind(2)-1);
        keyword3=corrResp(crFind(2)+1:end);
        keyword3b=corrResp(crFind(2)+1:end-1);
        possPoints=3;
    else
        wordSwitch=2;
        keyword1=corrResp(1:crFind(1)-1);
        keyword2=corrResp(crFind(1)+1:crFind(2)-1);
        keyword3=corrResp(crFind(2)+1:crFind(3)-1);
        keyword4=corrResp(crFind(3)+1:end);
        keyword4b=corrResp(crFind(3)+1:end-1);
        possPoints=4;
    end
    time=toc;
    pause(stimLength);
    
    %Now we are going to try to collect the responses
    strLength=length(stims{trialVar(i),2}); % Determine length of string for centering purposes
%     TextWidth=Screen(window,'TextWidth',stims{i,2});
%     TextHeight= strLength*(32+5)-5;
    DrawFormattedText(window, '+', 'center', 'center', colors.white);
    Screen('Flip', window);
%     cenTex3({''},window,screenRect,colors.black,white,32) % Display fixation cross
    if debug~=1
        FlushEvents('keyDown');
        [Response,string]=getTextResponses(window,'Target Sentence (Press enter when you are done):',Xorigin-Xorigin/1.2,Yorigin, colors.white, colors.black);
    else
        Response=corrResp;
    end
    time2=toc;
    newResponse=[' ' Response ' '];
    respFind=find(newResponse(:)==' ');
    numWords=length(respFind+1);
    points=0;
    
    for j=1:numWords-1
        word=newResponse(respFind(j)+1:respFind(j+1)-1);
        if wordSwitch==1;
            if strcmpi(keyword1, word)==1
                points=points+1;
            elseif strcmpi(keyword2, word)==1
                points=points+1;
            elseif strcmpi(keyword3, word)==1
                points=points+1;
            elseif strcmpi(keyword3b, word)==1
                points=points+1;
            end
        else
            if strcmpi(keyword1, word)==1
                points=points+1;
            elseif strcmpi(keyword2, word)==1
                points=points+1;
            elseif strcmpi(keyword3, word)==1
                points=points+1;
            elseif strcmpi(keyword4, word)==1
                points=points+1;
            elseif strcmpi(keyword4b, word)==1
                points=points+1;
            end
        end
    end
                
    totalpoints=totalpoints+points;
    totPos=totPos+possPoints;
    
    %In this part of the code, compute correct words per type of noise and
    %overall for display at the end of the experiment
    if strcmpi(stims{trialVar(i),3},'1T')==1
        score_1t=score_1t+points;
        poss1t=poss1t+possPoints;
    elseif strcmpi(stims{trialVar(i),3},'2Talker')==1
        score_2t=score_2t+points;
        poss2t=poss2t+possPoints;
    elseif strcmpi(stims{trialVar(i),3},'8Talker')==1
        score_8t=score_8t+points;
        poss8t=poss8t+possPoints;
    else
        score_ssn=score_ssn+points;
        possssn=possssn+possPoints;
    end

    %Display feedback
    points2=mat2str(points);
%     points2=['+' points2];
    pointsText=['You got ' points2 ' of the keywords correct!'];
%     Screen(
    DrawFormattedText(window, pointsText, 'center', 'center', colors.white);
    Screen('Flip',window);
%     cenTex3({pointsText},window,screenRect,colors.black,white,64) % Display feedback
    pause(1*speedup);
    
    %Display screen for next trial
    if i~=length(trialVar)
        instructions = ['Please press the space bar when you are ready for the next trial',...
        ''];

        DrawFormattedText(window, instructions, 'center', 'center', colors.white);
        Screen('Flip',window);
    %     cenTex3(instructions,window,screenRect,colors.black,white,18) % Display feedback
        if debug~=1;getResp('space');end; % Wait for user to press 'space bar'; % Wait for user to press 'space bar'  
%         if debug~=1;getResp_laptop('space');end;
    end
    
    %Collect data for saving later
    data{trialN,1}=trialN; %Trial Number
    data{trialN,2}=stims{trialVar(i),1}; %Stimulus file name
    data{trialN,3}=stims{trialVar(i),2}; %Stimulus sentence
    data{trialN,4}=stims{trialVar(i),3}; %Stimulus file type (noise type)
    data{trialN,5}=stims{trialVar(i),4}; %keywords used for correct response feedback
    data{trialN,6}=Response; %Response
    data{trialN,7}=wordSwitch; %length of keywords
    data{trialN,8}=time2; %Response time
%     data{trialN,9}=time; %Timer check
    data{trialN,9}=points;
    data{trialN,10}=totalpoints;
    data{trialN,11}=totPos;
    
    
    %Clear and reset information for next trial
    points=0;
    clear keyword1
    clear keyword2
    clear keyword3
    clear keyword4
    clear keyword3b
    clear keyword4b

    pause(.2*speedup) %pause 200ms before next sound plays
    
    
    
end

%Compute overall scores for the experiment
overall_1t=round(score_1t/poss1t*100);
overall_2t=round(score_2t/poss2t*100);
overall_8t=round(score_8t/poss8t*100);
overall_ssn=round(score_ssn/possssn*100);
overall=round(totalpoints/totPos*100);

% data2=[pid,overall_1t,overall_2t,overall_8t,overall_ssn,overall];

% Screen(window,'TextFont','Verdana'); % Set text font
% Screen(window,'FillRect', backcolor); % Fill background with backcolor
instructions = ['You have reached the end of the experiment.\n',...
    'Thank you very much for your participation!\n',...
    '\n',...
    'You got ' mat2str(overall_1t) '% of the 1 talker noise keywords correct!\n',...
    'You got ' mat2str(overall_2t) '% of the 2 talker noise keywords correct!\n',...
    'You got ' mat2str(overall_8t) '% of the 8 talker noise keywords correct!\n',...
    'You got ' mat2str(overall_ssn) '% of the white noise keywords correct!\n',...
    'And you got ' mat2str(overall) '% of the all words correct!\n',...
    '\n',... 
    'Please press ''e'' to exit. Thanks!'];

DrawFormattedText(window, instructions, 'center', 'center', colors.white);
Screen('Flip', window);

% cenTex3(instructions,window,screenRect,colors.black,white,18) % Print text centered
getResp('e');% Wait for experimenter to press 'Esc'
% getResp_laptop('e');

    