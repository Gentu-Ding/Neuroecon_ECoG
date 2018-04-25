
# opponent's data is drawn from #14 pairs of play

DataPath = ".\\Data\\"          ### for windows
#DataPath = "./Data/"               ### for Mac

import time,thread
import string,csv
import random
import os
import sys
import glob
from ctypes import windll

SetWindowPos = windll.user32.SetWindowPos

# PyGame Constants
import pygame
from pygame.locals import *
from pygame.color import THECOLORS

import box


width=800
height=600

BoxSize = (45,45)
BarSize = (3,2)
BarLength = 40
##    FontSize = 24
FontSize = 35
Position1 = (15,90)  # (x,y) for the first row of bars
Position2 = (15,90+160)  # for row 2
Position3 = (15, 200+250) # row 3
##    BarPosition = (100, 410)  # for bar
BarPosition = (100, 370)  # for bar
BackgroundColor = 0,0,0
BoxColor = 200,200,200
BoxColorGrey = 200,200,200
BoxColorGreen = 2,157,116
BoxColorRed = 139,35,35
BoxColorDarkGrey = 84,84,84


NOSIZE = 1
NOMOVE = 2
TOPMOST = -1
NOT_TOPMOST = -2

speedup=1

gIsPaused = False

doRepeat = False

wait2timer=0

timing = {"InterTrial" : random.uniform(500,500)/speedup,
          "NewRound" : random.uniform(2000,2000)/speedup,
              # "ChoicePresentation" : 2000/speedup,
              "SubjectChoice" : (4000)/speedup,
              "OpponentChoice" : 500.0/speedup,
              "Feedback" : 2000/speedup,
              # "ProfitDisplay" : 3000/speedup,
              "PausedScreen" : 10800000}

def writeMultipleLines(listOlines, underline = -1):
    global font
    center = (width/2, height/2)
    writeMultipleLinesHelper(listOlines, center, font, underline = -1)

def writeMultipleLinesHelper(listOlines, center, thefont, underline = -1, color = (255, 255, 255), bottom = False):
   totalY = 0
   surfs = list()
   rects = list()
   heights = list()
   for i, line in enumerate(listOlines):
      msg = line
      thefont.set_underline(i == underline)
      msgSurfaceObj = thefont.render(msg, True, color)
      msgRectobj = msgSurfaceObj.get_rect()
      heights.append(totalY)
      totalY = totalY + msgRectobj.height
      surfs.append(msgSurfaceObj)
      rects.append(msgRectobj)
   for index, therect in enumerate(rects):
      if bottom:
          therect.midtop = (center[0], center[1] - totalY + heights[index])
      else:
          therect.center = (center[0], center[1] - totalY/2 + heights[index])
      screen.blit(surfs[index], therect)


def message(listOlines):
    global stagename, screen, timing
    stagename = "Message"
    whiteOut()
    writeMultipleLines(listOlines)
    #writeQueue(roundnum,"Message")
    flipupdate()
    wait(timing["PausedScreen"])

def displayImage(filepath, stage="Message"):
    global stagename, screen, timing
    stagename = stage
    whiteOut()
    map_surface = pygame.image.load(filepath).convert_alpha()
    surface2 = pygame.transform.smoothscale(map_surface, (width, height))
    screen.blit(surface2, (0,0)) 
    #writeQueue(roundnum,stage)
    flipupdate()
    wait(timing["PausedScreen"])

def promptRepeat():
    global stagename, screen, timing, doRepeat, roundnum

    displayImage("Instructions_Strong/Experimenter_prompt.png", "Repeat")
    if doRepeat:
        roundnum = 0
        MainEvent(screen,Data,DataFile,Pay,PayFile,TimeStamp,TimeFile, OpponentFile, StartTime,SID,'strong',doInstructions=False,practice=1)
        promptRepeat()
        

def instructions():
    # Instructions
    message(["Patent Race Task",
             "",
             "Press return to move",
             "through the slides."])

    for path in sorted(glob.glob("Instructions_Strong/Box_intr_s*.png")):
        print(path)
        displayImage(path)

    # message(["In this game you will be given",
    #          "the choice between two bets:",
    #          "",
    #          "A Safe bet and a Risky bet",
    #          "",
    #          "The Safe bet will always give",
    #          "you the amount displayed.",
    #          "",
    #          "Click or Press ENTER to continue"])

    # message(["The risky bet has a shown digit",
    #          "and a hidden digit.",
    #          "",
    #          "If the hidden digit is LARGER",
    #          "than the shown digit, you win",
    #          "the amount displayed.",
    #          "Otherwise, you win nothing.",
    #          "",
    #          "Click or Press ENTER to continue"])

    #message(["Press {0} or left click to choose".format(lbuttonName),
    #         "the bet on the left",
    #         "",
    #         "Press {0} or right click to choose".format(rbuttonName),
    #         "the bet on the right",
    #         "",
    #         "Click or Press ENTER to continue"])

    message(["You have {0:.1f} seconds to".format(4000.0/1000.0),
             "make a decision in each round.",
             "",
             "If you do not make a decision",
             "the bars will turn red",
             "and you will earn nothing",
             "for that round.",
             "",
             "Click or Press ENTER to continue"])

    displayImage("Instructions_Strong/Practice_prompt.png")
    # message(["You will receive no payment",
    #          "for playing this game,",
    #          "but please try to make",
    #          "as much money as possible!",
    #          "",
    #          "Click or Press ENTER to continue"])

    # message(["Click or Press ENTER",
    #          "to start the game"])

        
def drawchoicebars(InvestA):
    bar(EndowmentA,screen,BoxSize,Position1,BackgroundColor, BoxColor,1)
    bar(InvestA,screen, BoxSize,Position1,BackgroundColor, BoxColorGrey,0)
    #grey out the payoff part
    bar(EndowmentA,screen,BoxSize,Position3,BackgroundColor, BoxColor,1)
    bar(Award,screen,BoxSize,(Position3[0]+(BoxSize[0]+1)*EndowmentA + 10,Position3[1]),BackgroundColor, BoxColorGreen,0)
    bar(InvestA,screen,BoxSize,Position3,BackgroundColor, BoxColorGrey,0)

def pauseInterrupt():
    #global stagename, screen, timing, pauseScreen
    # whiteOut()
    paused_text = font.render("Paused by experimenter", True, (0,0,0))
    prect = paused_text.get_rect()
    prect.center = screen.get_rect().center
    pauseScreen.blit(screen, (0, 0))
    pygame.draw.rect(screen, (150, 150, 150), prect)
    screen.blit(paused_text, prect)
    #writeQueue(round,"PauseBegin")
    flipupdate()

def pauseEnd():
    global pauseScreen
    whiteOut()
    screen.blit(pauseScreen, (0, 0))
    flipupdate()
    #writeQueue(round,"PauseEnd")

def wait_old(time_to_wait):
    """ waits a certain amount of time before game continues while keeping track of events. Uses a lot of CPU """
    global subjChoice, InvestAmount
    wait_start = time.time()
    temp_time = 0
    polling = True
    isPaused = False
    while polling and (temp_time < time_to_wait/1000 or isPaused):
        # If we start a pause, record the amount of time we've already waited
        # temp_time = time.time() - wait_start
        # Then, wehen we end the pause
        # wait_start = time.time() - temp_time
        if not isPaused:
            temp_time = time.time() - wait_start
        for event in pygame.event.get():
            handlerReturn = handler(event, 0)
            if handlerReturn == "startPause":
                isPaused = True
            elif handlerReturn == "endPause":
                isPaused = False
                wait_start = time.time() - temp_time
            elif not handlerReturn:
                polling = False


def wait(time_to_wait):
    global InvestAmount
    wait_old(time_to_wait)
    
    
def handler(event, wait2timer):
    global subjChoice, mainscreen, size
    global gIsPaused, doRepeat
    global InvestAmount, confirm
    
    
    confirm=0
    #print stagename
    #print canRespond
    
    """ Handles events. Return False to signal to stop handling."""
    if event.type == USEREVENT and event.key == wait2timer:
        return False
    if event.type == QUIT:
        print "Quit!"
        running = False
        pygame.quit()
        sys.exit()
        return False
    elif event.type == VIDEORESIZE:
        size = event.dict['size']
        mainscreen=pygame.display.set_mode(size,HWSURFACE|DOUBLEBUF|RESIZABLE)
        flipupdate()
    elif event.type == MOUSEBUTTONDOWN:
        if event.button == 1:   # Left Click
            if stagename == "Message":
                #writeQueue(roundnum,'AcknowledgeMessage')
                return False
            elif stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                subjChoice = 0
                return False
            else:
                writeQueue(roundnum,'Choice uncaught')
        elif event.button == 3: # Right Click
            if stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'R')
                subjChoice = 1
                return False
            else:
                writeQueue(roundnum,'Choice uncaught')
    elif event.type == KEYDOWN:
        #if event.key == K_5:
            #writeQueue(roundnum,'Pulse')
            #if stagename == "PausedScreen":
                #return False
        if event.key == K_p:
            retme = "startPause"
            if not gIsPaused:
                pauseInterrupt()
            else:
                pauseEnd()
                retme = "endPause"
            gIsPaused = not gIsPaused
            return retme
        if event.key in [K_RETURN, K_KP_ENTER] and stagename == "Instructions":
                #writeQueue(roundnum,'AcknowledgeInstructions')
                return False
        if event.key in [K_RETURN, K_KP_ENTER, K_SPACE] and stagename == "Message":
                #writeQueue(roundnum,'AcknowledgeMessage')
                return False
            
        #if event.key in [K_RETURN, K_KP_ENTER] and stagename == "SubjectChoice":
                #writeQueue(roundnum,'AcknowledgeMessage')

                #return False
            
        if event.key in [K_SPACE, K_RETURN, K_KP_ENTER, K_r] and stagename == "Repeat":
                #writeQueue(round,'AcknowledgeMessage')
                doRepeat = event.key == K_r;
                return False
            
        if event.key in [K_KP0, K_0] and stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                InvestAmount = 0
                drawchoicebars(InvestAmount)
                flipupdate()
            
        if event.key in [K_KP1, K_1] and stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                InvestAmount = 1
                drawchoicebars(InvestAmount)
                flipupdate()
                
        if event.key in [K_KP2, K_2] and stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                InvestAmount = 2
                drawchoicebars(InvestAmount)
                flipupdate()
                
        if event.key in [K_KP3, K_3] and stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                InvestAmount = 3
                drawchoicebars(InvestAmount)
                flipupdate()

        if event.key in [K_KP4, K_4] and stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                InvestAmount = 4
                drawchoicebars(InvestAmount)
                flipupdate()
                
        if event.key in [K_KP5, K_5] and stagename =="SubjectChoice" and canRespond:
                #writeChoice(roundnum,'L')
                InvestAmount = 5
                drawchoicebars(InvestAmount)
                flipupdate()
                
        if event.key in [K_RETURN, K_KP_ENTER, K_SPACE]and stagename =="SubjectChoice" and canRespond:
                 
                confirm=1
                return False
                

             
            #else:
                #writeQueue(roundnum,'Choice uncaught')
        
        if event.key == K_F1 or event.key == K_f:
            pygame.display.toggle_fullscreen()
        if event.key == K_ESCAPE:
            print "Testing"
            pygame.event.post(pygame.event.Event(QUIT))
    return True


    
def alwaysOnTop(yesOrNo):
    zorder = (NOT_TOPMOST, TOPMOST)[yesOrNo] # choose a flag according to bool
    hwnd = pygame.display.get_wm_info()['window'] # handle to the window
    SetWindowPos(hwnd, zorder, 0, 0, 0, 0, NOMOVE|NOSIZE)


def whiteOut():
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill((0, 0, 0))
    screen.blit(background, (0, 0))

def bar(TotalBox,screen,size,position,BackgroundColor, BoxColor,SOLID):
    x = position[0]
    # horizontal bars
    count = 1
    while count <=TotalBox:
        #x = x + size[0]+1
        x = x + size[0]+ 3
        count = count +1
        boxA = box.Box( screen, size, (x,position[1]), BackgroundColor, BoxColor)
        if SOLID == 1:
            boxA.draw()
        else:
            boxA.drawOpen()

def spacing_bar(TotalBox,screen,size,position,BackgroundColor, BoxColor):
    x = position[0]
    # horizontal bars
    count = 1
    while count <=TotalBox:
        x = x + size[0]*5
        count = count +1
        boxA = box.Box( screen, size, (x,position[1]), BackgroundColor, BoxColor)
        boxA.draw()

def blackbox(black = 1):
    size = 70
    size2 = 70
    pygame.draw.rect(screen, (255, 255, 255), (0, height - size2, size2, size2))    
    color = (255, 255, 255) if black else (0, 0, 0)
    pygame.draw.rect(screen, color, (0, height - size, size, size))
    
def disblackbox(black = 0):
    size = 70
    size2 = 70
    pygame.draw.rect(screen, (0, 0, 0), (0, height - size2, size2, size2))    
    color = (0, 0, 0)
    pygame.draw.rect(screen, color, (0, height - size, size, size))        
        
def flipupdate(black = 0):
    global screen, mainscreen, size
    if black:
        blackbox(black)
    mainscreen.blit(pygame.transform.smoothscale(screen,size),(0,0))
    pygame.display.flip()
    

def payoff(InvestA, InvestB,EndowmentA,EndowmentB,Award):
    if InvestA > InvestB:
        utility = Award + EndowmentA - InvestA
    elif InvestA <=InvestB:
        utility = EndowmentA - InvestA
    return utility


def waitforspacebar():
    pygame.event.clear()
    event=pygame.event.wait()
    while (event.type != KEYDOWN) or (event.type == KEYDOWN and event.key != K_SPACE):
            event=pygame.event.wait()

def GetPayRound(PayRounds, noofgames):   
    tmplist = []
    for index in range(noofgames):
        tmplist.append(index+1)
        
    for index in range(noofgames-PayRounds):
        tmplist.pop(random.randrange(len(tmplist)))
        
    return tmplist

def GetList(FileName):
    f = open(FileName)
    AllLines = list(f)
    f.close()
    for idx in range(len(AllLines)):
        AllLines[idx] = AllLines[idx].rstrip('\n')
    return AllLines                

def Hurdle(Dist):
    import random
    draw = random.randrange(100)
    for idx in range(len(Dist)):
        if draw <= Dist[idx]:
            break
    return idx

def MainEvent(screen,Data,DataFile,Pay,PayFile, TimeStamp,TimeFile, OpponentFile, StartTime, SID, role,doInstructions,practice):                    
    global Mainlock
    global End
    global FinalPayoff
    global FinalCount
    global mainscreen,size,width,height,font
    global Award, EndowmentA, InvestAmount
    global stagename,canRespond
    
    
    rounds = 20
    #PayRounds = rounds
    pair = 14

    if practice==True:
        rounds=1

    PayRounds = 10
        
        
    
        

    
    
    EndowmentHigh = 5
    EndowmentLow = 4
    Award = 10

    End=0
    width = 800
    height = 600
    size = (width, height)

    WINSIZE = 800,600
    #screen = pygame.Surface((800, 600), pygame.SRCALPHA, 32)
    #mainscreen = pygame.display.set_mode((width, height), HWSURFACE | DOUBLEBUF | RESIZABLE)
##    BoxSize = (24,24)
    BoxSize = (45,45)
    BarSize = (3,2)
    BarLength = 40
##    FontSize = 24
    FontSize = 35
    Position1 = (15,90)  # (x,y) for the first row of bars
    Position2 = (15,90+160)  # for row 2
    Position3 = (15, 200+250) # row 3
##    BarPosition = (100, 410)  # for bar
    BarPosition = (100, 370)  # for bar
    BackgroundColor = 0,0,0
    BoxColor = 200,200,200
    BoxColorGrey = 200,200,200
    BoxColorGreen = 2,157,116
    BoxColorRed = 139,35,35
    BoxColorDarkGrey = 84,84,84
    
      
    RoundPaid = GetPayRound(PayRounds, rounds)

    # read opponent's file
    tmpData =GetList(OpponentFile)
    Opponent = []
    for l in tmpData:       # header included
        ll = l.split(',')
        Opponent.append(ll)


    round = 1
    index = 0   # index for Opponent( header is 0)
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill((0, 0, 0))
    screen.blit(background, (0, 0))

    
    flipupdate()
    wait(timing["NewRound"])
    
    #waitforspacebar()
    if doInstructions:
        instructions()
    
    
    while round <= rounds  :

        canRespond=False
        # Random draw the same round from opponent
        drawRound = index + random.randrange(pair)+1
        tmpOpp= Opponent[drawRound]
        index = pair + index
        
        if role == "strong":
            EndowmentA = EndowmentHigh      # EndowmentA and InvestA are this player
            EndowmentB = EndowmentLow       # EndowmentB and InvestB are for opponent
            InvestB = int(tmpOpp[7])
        if role == "weak":
            EndowmentA = EndowmentLow
            EndowmentB = EndowmentHigh
            InvestB = int(tmpOpp[6])


        ##########
        # return to initial state
        map_surface = pygame.image.load("all_black.jpg").convert()
        screen.blit(map_surface, (0,0))
        flipupdate()
        wait(timing["InterTrial"])
        
        background = pygame.Surface(screen.get_size())
        background = background.convert()
        background.fill((0, 0, 0))
        screen.blit(background, (0, 0))


        rw, rh = 10, 100
        pygame.draw.rect(screen, (255, 255, 255), (width/2 - rw/2, height/2-rh/2, rw, rh))
        pygame.draw.rect(screen, (255, 255, 255), (width/2 - rh/2, height/2-rw/2, rh, rw))
    
        #pygame.display.flip()
        flipupdate()
        #waitforspacebar()
        wait(timing["NewRound"])
        #pygame.time.wait(2000)
        
        #show choice stimuli 
        map_surface = pygame.image.load("all_black.jpg").convert()
        screen.blit(map_surface, (0,0))
    
##        # Draw line separating payoff and decisions
##        spacing_bar(BarLength, screen,BarSize,BarPosition,BackgroundColor, BoxColorDarkGrey)
        spacing_bar(BarLength, screen,BarSize,BarPosition,BackgroundColor, BoxColorGrey)
        #pygame.display.flip()
        #flipupdate()
        
        # label
        
        if pygame.font:
            font = pygame.font.Font(None, FontSize)
            textA = font.render("You", 1, (255,255,255),BackgroundColor)
            textposA = (Position1[0]+70,Position1[1]-FontSize*1.1)
            screen.blit(textA, textposA)
            
            textB = font.render("Opponent", 1, (255,255,255),BackgroundColor)
            textposB = (Position2[0]+70,Position2[1]-FontSize*1.1)
            screen.blit(textB, textposB)

            textC = font.render("Payoff", 1,(255,255,255),BackgroundColor)
            textposC = (Position3[0]+70,Position3[1]-FontSize*1.1)
            screen.blit(textC, textposC)

            textC = font.render(str(EndowmentA)+" + " +str(Award), 1,(255,255,255),BackgroundColor)
            textposC = (Position3[0]+ 100 + 100,Position3[1]-FontSize*1.1)
            screen.blit(textC, textposC)

            textC = font.render(str(round), 1, (255,255,255),BackgroundColor)
            textposC = (WINSIZE[0]-50,FontSize)
            screen.blit(textC, textposC)

        # bars for endowments and award
        bar(EndowmentA,screen,BoxSize,Position1,BackgroundColor, BoxColor,1)
        bar(EndowmentB,screen,BoxSize,Position2,BackgroundColor, BoxColor,1)
        bar(EndowmentA,screen,BoxSize,Position3,BackgroundColor, BoxColor,1)
##        bar(Award,screen,BoxSize,(Position3[0]+(BoxSize[0]+1)*EndowmentA,Position3[1]),BackgroundColor, BoxColorGreen,0)
        bar(Award,screen,BoxSize,(Position3[0]+(BoxSize[0]+1)*EndowmentA + 10,Position3[1]),BackgroundColor, BoxColorGreen,0)
        spacing_bar(BarLength, screen,BarSize,BarPosition,BackgroundColor, BoxColorGrey)
        
        #pygame.display.update()
        flipupdate(1)
        #print textA
        
        #MainLock.acquire()
        TimeStamp.writerow([round,practice,'PresentGame',str(time.clock()-StartTime)])
        TimeFile.flush()

        
##        ###########
##        #### investment decision
##        pygame.time.wait(2000)
##        # change bar into green
        #spacing_bar(BarLength, screen,BarSize,BarPosition,BackgroundColor, BoxColorGrey)
        #flipupdate()
        #pygame.display.update()

        
        ### select investment
        #wait_start=time.clock()
        #InvestA = 0
        #done = False
        #pygame.event.clear()
        #temp_time=0
        #time_to_wait=random.uniform(4000,4000)


        #Make the Investment Choice
        
        InvestAmount = 0
        stagename="SubjectChoice"
        
        canRespond=True
        

        wait(timing["SubjectChoice"])
        
            
        canRespond=False    
            
        if confirm==0:

            TimeStamp.writerow([round,practice,'ChoiceUncaught',str(time.clock()-StartTime)])
            TimeFile.flush()
            
            Payoff = 0   
            textD = font.render("You did not confirm in time ! " , 1,BoxColorRed,BackgroundColor)
            textposD = (Position1[0]+50,Position1[1]+FontSize*1.5)
            screen.blit(textD, textposD)
            textD = font.render("You received " + str(Payoff), 1,BoxColorRed,BackgroundColor)
            textposD = (Position3[0]+50,Position3[1]+FontSize*1.5)
            screen.blit(textD, textposD)
            #pygame.display.update()
            bar(EndowmentHigh,screen, BoxSize,Position1,BackgroundColor, BoxColorRed,0)
            bar(EndowmentLow,screen, BoxSize,Position2,BackgroundColor, BoxColorRed,0)
            bar(EndowmentHigh+Award,screen,BoxSize,Position3,BackgroundColor, BoxColorRed,0)
            disblackbox()
            flipupdate()
            wait(timing["Feedback"])
            #pygame.display.update()
            #map_surface = pygame.image.load("all_black.jpg").convert()
            #screen.blit(map_surface, (0,0))
            #flipupdate()
            #pygame.time.wait(500) 
            
            WriteList = [SID,str(round),practice,str(drawRound),str(EndowmentA),str(EndowmentB),str(Award),'/','/','/']
            Data.writerow(WriteList)
            DataFile.flush()
            
            #WriteList = [str(round),practice,str(EndowmentA),str(Award),'/','/','/']
            #Pay.writerow(WriteList)
            #PayFile.flush()
            
            FinalPayoff = FinalPayoff + Payoff
            FinalCount = FinalCount + 1
            
            round = round +1
            continue

        
        if End == 1:
            print "Quit!"
        
            pygame.quit()
            sys.exit()
            break
            
        #MainLock.acquire()
        TimeStamp.writerow([round,practice,'ChoiceMade',str(time.clock()-StartTime)])
        TimeFile.flush()
        
        
        
        # show A's
        print InvestAmount
        InvestA=InvestAmount
        
        textD = font.render("You invested " + str(InvestA), 1,BoxColorGreen,BackgroundColor)
        textposD = (Position1[0]+50,Position1[1]+FontSize*1.5)
        screen.blit(textD, textposD)
        #pygame.display.update()
        #whiteOut()
        disblackbox()
        flipupdate()
        wait(timing["OpponentChoice"])
        
        Payoff = payoff(InvestA, InvestB,EndowmentA, EndowmentB, Award)   
           
        
        # label
        if pygame.font:
            font = pygame.font.Font(None, FontSize)
            textA = font.render("You", 1, (255,255,255),BackgroundColor)
            textposA = (Position1[0]+70,Position1[1]-FontSize*1.1)
            screen.blit(textA, textposA)
            
            textB = font.render("Opponent", 1, (255,255,255),BackgroundColor)
            textposB = (Position2[0]+70,Position2[1]-FontSize*1.1)
            screen.blit(textB, textposB)

            textC = font.render("Payoff", 1,(255,255,255),BackgroundColor)
            textposC = (Position3[0]+70,Position3[1]-FontSize*1.1)
            screen.blit(textC, textposC)

            textC = font.render("               ", 1,(255,255,255),BackgroundColor)
            textposC = (Position3[0]+ 100 + 100,Position3[1]-FontSize*1.1)
            screen.blit(textC, textposC)

            textC = font.render(str(round), 1, (255,255,255),BackgroundColor)
            textposC = (WINSIZE[0]+150,FontSize)
            screen.blit(textC, textposC)
            
            # show A's
            textD = font.render("You invested " + str(InvestA), 1,BoxColorGreen,BackgroundColor)
            textposD = (Position1[0]+50,Position1[1]+FontSize*1.5)
            screen.blit(textD, textposD)
        
        #MainLock.acquire()
        TimeStamp.writerow([round,practice,'StartFeedback',str(time.clock()-StartTime)])
        TimeFile.flush()  
            
        # bars for endowments and award
        bar(EndowmentA,screen,BoxSize,Position1,BackgroundColor, BoxColor,1)
        bar(EndowmentB,screen,BoxSize,Position2,BackgroundColor, BoxColor,1)
        bar(EndowmentA,screen,BoxSize,Position3,BackgroundColor, BoxColor,1)
        bar(Award,screen,BoxSize,(Position3[0]+(BoxSize[0]+1)*EndowmentA + 10,Position3[1]),BackgroundColor, BoxColorGreen,0)
        #pygame.display.update()
        flipupdate()
        # show payoff text
        textC = font.render("Your Payoff", 1, (255,255,255),BackgroundColor)
        textposC = (Position3[0]+50,Position3[1] -FontSize*1.1)
        screen.blit(textC, textposC)
        # show B's investment
        textD = font.render("Opponent invested " + str(InvestB), 1,BoxColorGreen,BackgroundColor)
        textposD = (Position2[0]+50,Position2[1]+FontSize*1.5)
        screen.blit(textD, textposD)
        # show payoff
        textD = font.render("You received " + str(Payoff), 1,BoxColorGreen,BackgroundColor)
        textposD = (Position3[0]+50,Position3[1]+FontSize*1.5)
        screen.blit(textD, textposD)
        # show  bars
        bar(InvestB,screen, BoxSize,Position2,BackgroundColor, BoxColorGrey,0)
        bar(InvestA,screen, BoxSize,Position1,BackgroundColor, BoxColorGrey,0)
        if InvestA > InvestB:
            bar(EndowmentA,screen,BoxSize,Position3,BackgroundColor, BoxColor,1)
            bar(Award,screen,BoxSize,(Position3[0]+(BoxSize[0]+1)*EndowmentA + 10,Position3[1]),BackgroundColor, BoxColorGreen,1)
            bar(InvestA,screen,BoxSize,Position3,BackgroundColor, BoxColorGrey,0)
        else:
            bar(EndowmentA,screen,BoxSize,Position3,BackgroundColor, BoxColor,1)
            bar(Award,screen,BoxSize,(Position3[0]+(BoxSize[0]+1)*EndowmentA + 10,Position3[1]),BackgroundColor, BoxColorRed,0)
            bar(InvestA,screen,BoxSize,Position3,BackgroundColor, BoxColorGrey,0)
        #pygame.display.update()
        flipupdate()

        # write datafile
        WriteList = [SID,str(round),practice,str(drawRound),str(EndowmentA),str(EndowmentB),str(Award),str(InvestA),str(InvestB),str(Payoff)]
      

        Data.writerow(WriteList)
        DataFile.flush()
        if RoundPaid.count(round) > 0:
            WriteList = [str(round),practice,str(EndowmentA),str(Award),str(InvestA),str(InvestB),str(Payoff)]
            Pay.writerow(WriteList)
            PayFile.flush()
            FinalPayoff = FinalPayoff + Payoff
            FinalCount = FinalCount + 1
            
        #MainLock.acquire()
        #TimeStamp.writerow([round,'EndFeedback',str(time.clock()-StartTime)])
        #TimeFile.flush()  

 
        wait(timing["Feedback"])
        #pygame.time.wait(2000)
        
        #MainLock.acquire()
        TimeStamp.writerow([round,practice,'EndFeedback',str(time.clock()-StartTime)])
        TimeFile.flush() 
       
        #waitforspacebar()
        # show a blank screen
        #map_surface = pygame.image.load("all_black.jpg").convert()
        #screen.blit(map_surface, (0,0))
        #rw, rh = 10, 100
        #pygame.draw.rect(screen, (250, 250, 250), (width/2 - rw/2, height/2-rh/2, rw, rh))
        #pygame.draw.rect(screen, (250, 250, 250), (width/2 - rh/2, height/2-rw/2, rh, rw))
        #pygame.display.update()
        #flipupdate()
        #pygame.time.wait(500)
        #map_surface = pygame.image.load("all_black.jpg").convert()

        #screen.blit(map_surface, (0,0))
        #flipupdate()
        
        round = round +1

    # end of the experiment
    screen.fill(BackgroundColor)
    pygame.display.flip()


    

##############################################    
##############################################
   
SID = raw_input("Please input subject ID: ")
#OpponentFile = "data" + raw_input("Please input block number: ") + ".csv"




# open data file
DataFileName = DataPath + str(SID)+'.csv'
DataFile = open(DataFileName,"wb")
Data = csv.writer(DataFile)
Data.writerow(['SID','Round','Practice','DrawRound','MyEndowment','OpponentEndowment','Award','MyInvestment','OpponentInvest','MyPayoff'])
DataFile.flush()
# this is the file for payment
PayFileName = DataPath + str(SID)+'_pay.csv'
PayFile = open(PayFileName,"wb")
Pay = csv.writer(PayFile)
Pay.writerow(['Round','Practice','MyEndowment','Award','MyInvest','OppentInvest','MyPayoff'])
PayFile.flush()
# this is for time stamp
TimeFileName = DataPath + str(SID)+'_time.csv'
TimeFile = open(TimeFileName,"wb")
TimeStamp = csv.writer(TimeFile)
TimeStamp.writerow(['Round','Practice','Event','Time'])
TimeFile.flush()
# this is for payment for all players
ResultFileName = DataPath +'result.csv'
ResultFile = open(ResultFileName,"a")
Result = csv.writer(ResultFile)

# initiate pygame

#os.environ['SDL_VIDEO_CENTERED'] = '1'
pygame.init()
pygame.mixer.init()
pygame.font.init()
End = 0
#screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
#screen = pygame.display.set_mode((1366,768),FULLSCREEN)
#screen = pygame.display.set_mode((width,height),FULLSCREEN)
mainscreen = pygame.display.set_mode((width, height), HWSURFACE | DOUBLEBUF | RESIZABLE)
screen = pygame.Surface((width, height), pygame.SRCALPHA, 32)
#screen = pygame.display.set_mode((width,height),HWSURFACE | DOUBLEBUF | RESIZABLE)
pauseScreen = screen.copy()
#SetWindowPos(pygame.display.get_wm_info()['window'], -1, x, y, 0, 0, 0x0001)
alwaysOnTop(1)
pygame.display.flip()
font = pygame.font.Font(None, FontSize)
pygame.display.set_caption("Welcome to the Experiment")
pygame.mouse.set_visible(0)

# Set stating time
StartTime = time.clock()
TimeStamp.writerow(['','StartTime',str(time.clock()-StartTime)])

FinalPayoff = 0
FinalCount = 0
OpponentFile = "data.csv"
#OpponentFile = "data2" + ".csv"
#MainEvent(screen,Data,DataFile,Pay,PayFile,TimeStamp,TimeFile, OpponentFile, StartTime,SID,'weak')
MainEvent(screen,Data,DataFile,Pay,PayFile,TimeStamp,TimeFile, OpponentFile, StartTime,SID,'strong',doInstructions=True,practice=1)
promptRepeat()


MainEvent(screen,Data,DataFile,Pay,PayFile,TimeStamp,TimeFile, OpponentFile, StartTime,SID,'strong',doInstructions=False,practice=0)

DataFile.close()
PayFile.close()
TimeFile.close()


# save payment in a file
Result.writerow([str(SID),'strong' ,str((FinalPayoff/FinalCount)+1)])
ResultFile.flush()

waitforspacebar()
waitforspacebar()
pygame.display.quit()

    



    
