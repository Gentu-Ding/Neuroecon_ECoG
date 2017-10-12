#!/usr/bin/env python
# Gamble game
# Joshua Moller-Mara
# Version 1.2 (June 4th, 2014)

import pygame, sys, csv, time, thread, Queue, random
from pygame.locals import *
from pygame.compat import geterror
import pygame.gfxdraw
import pygame.mixer
import math
import glob

pi = math.pi

width = 800
height = 600
size = (width, height)
fullScreen = True
pausedRound = -1
framerate = 15                  # FPS

wincolor = (0, 128, 0)               # #008000
losecolor = (255, 0, 0)              # #ff0000
selectcolor = (147, 162, 153)        # #93a299

# when wrong
wrongselectcolor = (200, 162, 153)
notnormalcolor = (255, 204, 204)
wrongcolor = (255, 0, 0)
numberwrongcolor = (200, 0, 0)
confirmwrongcolor = (255, 0, 0)

# selectbordercolor = (108, 119, 113)  # #6c7771
selectbordercolor = (0, 0, 255)      # #0000ff
readycolor = (255, 255, 0)           # #ffff00
noselectcolor = (255, 0, 0)          # #ff0000
normalcolor = (204, 204, 204)        # #cccccc
fontcolor = (102, 102, 102)          # #666666
numberfontcolor = (77, 77, 77)       # #4d4d4d

targetsize = 150
liltargetsize = 110
radius = 100

lbuttons = [K_1]
rbuttons = [K_3]
#confirmed = False
lbuttonName = "1"
rbuttonName = "3"
choiceTime = 2
lchoice = None
rchoice = None

gIsPaused = False

class RoundInfo:
    """ Contains information needed for one round.
    Left/right payment, left/right presses, left/right time. """
    def __init__(self, csvrow):
        """ Take in a CSV row and initialize values. """
        def riskswap(riskSide, riskVal, safeVal):
            if riskSide == "Left":
                return (riskVal, safeVal)
            return (safeVal, riskVal)
        #csvrow[1] = '30' # gamble profit now set to $30
        safePay, riskPay, riskShow, riskHide, riskSide, trialType= csvrow
        self.payment = riskswap(riskSide, int(riskPay), int(safePay))
        self.isRisk  = riskswap(riskSide, True, False)
        self.showNum = riskswap(riskSide, int(riskShow), None)
        self.hideNum = riskswap(riskSide, int(riskHide), None)
        self.origline = csvrow
        self.roundtype = trialType

    def dictOut(self):
        return dict([(name, item)
                      for name, item in
                      zip(["Safe.Pay", "Risk.Pay", "Risk.Shown",
                           "Risk.Hidden", "Risk.Side","Trial.Type"], 
                          self.origline)])
    
def readInfo(thefile, nrounds= 1000):
    with open(thefile, 'rU') as csvfile:
        trialreader = csv.reader(csvfile)
        trialreader.next()          # Skip header
        rounds_list = [RoundInfo(row) for row in trialreader]
    lenrounds = min(len(rounds_list), nrounds)
    #rounds_list = random.sample(rounds_list, lenrounds)
    print "Payoffs read from " + thefile
    print "Number of rounds = " + str(nrounds)
    return rounds_list

# nrounds = 1
# rounds_list = readInfo("data/gamble_choices.csv", 1)

# testing purposes only
test = False
speedup = 1
if test:
    nrounds = 38
    speedup = 100 # for testing purposes only - otherwise set at 1
    print "Testing mode ON: nrounds=" + str(nrounds) + "; speedup=" + str(speedup) + "x"

# Create file to write data to
def setupWriters(SID, practice):
    global TimeFile, totalprofit, proffile, ProfCSV, TimeStamp, theOrder
    DataPath = 'output/'
    practiceString = "_practice" if practice else ""
    TimeFileName = DataPath+'Gamble' + practiceString + '_s'+str(SID)+'.csv'
    TimeFile = open(TimeFileName,"wb")
    TimeStamp = csv.writer(TimeFile)
    theOrder = [ "Round", "Event", "Choice", "Time",
                 "Safe.Pay", "Risk.Pay", "Risk.Shown", "Risk.Hidden", "Risk.Side",
                 'RiskyOrSafeChoice','Profit','TotalProfit']
    TimeStamp.writerow(theOrder)
    TimeFile.flush()

    totalprofit = 0
    # proffile = open(DataPath + 'Gamble_profit_s' + str(SID) + '.csv', "wb")
    # ProfCSV = csv.writer(proffile)
    # profWrite(['Round', 'SafeAmount', 'RiskyAmount', 'ShownNumber', 'HiddenNumber', 'RiskySide', 'RiskyOrSafeChoice','SideChoice','Profit','TotalProfit'])

    settingsfile = open(DataPath + 'Gamble_settings' + practiceString + '_s' + str(SID) + '.csv', "wb")
    settingsCSV = csv.writer(settingsfile)
    settingsCSV.writerow(['SID', 'SubjectDecisionTime', 'LeftKey', 'RightKey'])
    settingsCSV.writerow([str(SID), str(choiceTime), str(lbuttonName), str(rbuttonName)])
    settingsfile.flush()

def profWrite(lMessage):
    global ProfCSV, proffile
    ProfCSV.writerow(lMessage)
    proffile.flush()

class Choice:
    """ Draws a square area displaying:
    Payment
    Number of presses necessary
    Time needed to complete """
    def __init__(self, coord, size):
        self.size = size
        self.coord = coord
        self.x_pos = coord[0]
        self.y_pos = coord[1]
        self.payment = 0
        self.rect = Rect((0, 0), size)
        self.rect.center = coord
        self.smallfont = pygame.font.Font(None, 60)
        self.color = (0, 0, 0)
        self.fontcolor = fontcolor
        self.numberfontcolor = numberfontcolor
        self.normalcolor = normalcolor
        self.selectcolor = selectcolor

    def update(self, roundInfo, ind):
        self.isRisk = roundInfo.isRisk[ind]
        self.payment = roundInfo.payment[ind]
        self.showNum = roundInfo.showNum[ind]
        self.hideNum = roundInfo.hideNum[ind]
        self.profit = self.payment
        if self.isRisk:
            self.profit = self.payment if self.hideNum > self.showNum else 0
        self.color = (0, 0, 0)
        self.isReveal = False
        self.selected = False
        self.bordercolor = None
        self.fontcolor = fontcolor
        self.numberfontcolor = numberfontcolor
        self.normalcolor = normalcolor
        self.selectcolor = selectcolor

    def reveal(self):
        self.isReveal = True

    def penalty(self):
        self.payment = self.payment - 0
        self.normalcolor = notnormalcolor
        self.selectcolor = wrongselectcolor
        self.fontcolor = wrongcolor
        self.numberfontcolor = numberwrongcolor

    def draw(self):
        screen.blit(liltargetObj, ((width-liltargetsize)/2, (height-liltargetsize)/2 - 30))

        pygame.draw.rect(screen, self.normalcolor, self.rect)
        if self.bordercolor is not None:
            pygame.draw.rect(screen, self.bordercolor, self.rect, 3)
        elif self.selected:
            pygame.draw.rect(screen, self.selectcolor, self.rect)
            pygame.draw.rect(screen, selectbordercolor, self.rect, 3)
        if self.isRisk:
            self.drawRisk()
        else:
            self.drawSafe()

    def drawSafe(self):
        global isChoiceBlock, confirmed, subjChoice
        
        if self.isReveal:
            
            if (not isChoiceBlock) and (not confirmed):
                updatetext=["You lose!"]
                
                writeMultipleLinesHelper(updatetext,
                                      (self.coord[0], self.coord[1]), self.smallfont, color = self.fontcolor)
            elif subjChoice is None:
                newcolor = self.fontcolor
                #updatetext = ["${0}".format(self.payment)]
                updatetext = ["You lose!"]

                writeMultipleLinesHelper(updatetext,
                        (self.coord[0], self.coord[1]), self.smallfont, color = noselectcolor)
            else:
                writeMultipleLinesHelper(["${0}".format(self.payment)],
                                (self.coord[0], self.coord[1]), self.smallfont, color = self.fontcolor)
        else:
            writeMultipleLinesHelper(["${0}".format(self.payment)],
                                (self.coord[0], self.coord[1]), self.smallfont, color = self.fontcolor)

    def drawRisk(self):
        global winlose, subjChoice, isChoiceBlock,confirmed
    
        movedown = 35

        selectInd = 1 if self.selected else 0

        psurf = scaledWheelObjs[self.showNum]
        prect = psurf.get_rect()
        prect.center = (self.rect.center[0], self.rect.center[1]+movedown)
        screen.blit(psurf, (prect[0], prect[1]))
        screen.blit(centerdotObj, (prect[0], prect[1]))

        wheelcenter = (self.rect.center[0], self.rect.center[1]+movedown)
        # pygame.draw.circle(screen, (200, 0, 0), wheelcenter, 100)
        # pygame.draw.circle(screen, (0, 0, 0), wheelcenter, 100, 2)

        # arcrect = (wheelcenter[0]-100, wheelcenter[1]-100, 200, 200)
        # pygame.draw.arc(screen, (0, 0, 0), arcrect, -90, -90-360*int(self.showNum)/11, 3)


        grey = self.normalcolor
        #writeOneLine(str(self.showNum), ((prect.left + prect.centerx)/2, prect.centery), self.smallfont, color = self.numberfontcolor)
        if self.isReveal:
            # endpt = (prect.center[0]+ends[int(self.hideNum)][0], prect.center[1]+ends[int(self.hideNum)][1])
            # pygame.draw.line(screen, (0,0,0), prect.center, endpt, 2)
            # triangle = [(prect.center[0] + corner[0], prect.center[1] + corner[1]) for corner in triangles[int(self.hideNum)]]
            # pygame.draw.polygon(screen, (0,0,0), triangle)

            arrow = scaledArrowObjs[self.hideNum]
            arect = arrow.get_rect()
            arect.center = prect.center
            screen.blit(arrow, (arect[0], arect[1]))
            pygame.draw.circle(screen, (5,5,5), wheelcenter, 4)

            newcolor = wincolor if self.hideNum > self.showNum else losecolor
            winlose = 2 if self.hideNum > self.showNum else 1

            wintexts = ["You win", "${0}".format(self.payment)] if cur_type == "Self" else ["You win", "${0} for charity".format(self.payment)]
            losetexts = ["You lose!"] if cur_type == "Self" else ["You win nothing"," for charity!"]

            #finalfont = pygame.font.Font(None, 55) if cur_type == "social" and self.hideNum <= self.showNum else self.smallfont
            finalfont = pygame.font.Font(None, 35) if cur_type == "Social" else self.smallfont
            updatetext = wintexts if self.hideNum > self.showNum else losetexts
            if not self.selected:
                newcolor = losecolor if self.hideNum > self.showNum else wincolor
                winlose = 0 if self.hideNum < self.showNum else 1

                wintexts = ["You would","have won ${0}".format(self.payment)] if cur_type == "Self" else ["You would have","won ${0} for charity".format(self.payment)]
                losetexts = ["You would", "have lost!"] if cur_type == "Self" else ["You would have", "won nothing for charity!"]

                #finalfont = pygame.font.Font(None, 35) if cur_type == "social" else self.smallfont
                finalfont = pygame.font.Font(None, 35)
                updatetext = wintexts if self.hideNum > self.showNum else losetexts
            if (not isChoiceBlock) and (not confirmed):
                updatetext=["You lose!"]
                newcolor=losecolor
                winlose=1
                finalfont=pygame.font.Font(None, 55)
            if subjChoice is None:
                newcolor = self.fontcolor
                #updatetext = ["${0}".format(self.payment)]
                updatetext = ["You lose!"]
                winlose=1
                newcolor=losecolor
                finalfont=pygame.font.Font(None, 55)
            #writeOneLine(str(self.hideNum), ((prect.right + prect.centerx)/2, prect.centery), self.smallfont, color = newcolor)
            writeMultipleLinesHelper(updatetext,
                                      (prect.midtop[0],prect.midtop[1]-10), finalfont, color = newcolor, bottom = True) 
        else:
            writeMultipleLinesHelper(["${0}".format(self.payment)],
                                     (prect.midtop[0],prect.midtop[1]-20), self.smallfont, color = self.fontcolor) 

def sleepTimer(time_to_wait, message):
    time.sleep(time_to_wait/1000.0)
    pygame.event.post(pygame.event.Event(USEREVENT, key=message))

wait2timer = 0
def wait2(time_to_wait):
    "Waits while handling events. Does not busy wait (using CPU), instead creates a thread to tell pygame to break."
    global wait2timer
    wait2timer += 1
    thread.start_new_thread(sleepTimer,(time_to_wait, wait2timer))
    while True:
        event = pygame.event.wait()
        if not handler(event, wait2timer):
            break

def handler(event, wait2timer):
    global subjChoice, mainscreen, size
    global gIsPaused, doRepeat
    global confirmed
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
                writeQueue(roundnum,'AcknowledgeMessage')
                return False
            elif stagename =="SubjectChoice" and canRespond and not isChoiceBlock:
                pos = pygame.mouse.get_pos()
                print "positions ", pos
                print lchoice.selected, lchoice.rect.collidepoint(pos)
                print rchoice.selected, rchoice.rect.collidepoint(pos)
                if (lchoice.selected and lchoice.rect.collidepoint(pos)) or (rchoice.selected and rchoice.rect.collidepoint(pos)):
                    confirmed = True
                    writeQueue(roundnum, 'Choice confirmation')
                else:
                    writeQueue(roundnum, 'Wrong choice')
                return False
            elif stagename =="SubjectChoice" and canRespond:
                writeChoice(roundnum,'L')
                subjChoice = 0
                return False
            else:
                writeQueue(roundnum,'Choice uncaught')
        elif event.button == 3: # Right Click
            if stagename =="SubjectChoice" and canRespond and isChoiceBlock:
                writeChoice(roundnum,'R')
                subjChoice = 1
                return False
            else:
                writeQueue(roundnum,'Choice uncaught')
    elif event.type == KEYDOWN:
        if event.key == K_5:
            writeQueue(roundnum,'Pulse')
            if stagename == "PausedScreen":
                return False
        if event.key == K_p:
            retme = "startPause"
            if not gIsPaused:
                pauseInterrupt()
            else:
                pauseEnd()
                retme = "endPause"
            gIsPaused = not gIsPaused
            return retme
        if event.key in [K_RETURN, K_KP_ENTER, K_5] and stagename == "Instructions":
                writeQueue(roundnum,'AcknowledgeInstructions')
                return False
        if event.key in [K_RETURN, K_KP_ENTER] and stagename == "Message":
                writeQueue(roundnum,'AcknowledgeMessage')
                return False
        if event.key in [K_SPACE, K_RETURN, K_KP_ENTER, K_r] and stagename == "Repeat":
                writeQueue(round,'AcknowledgeMessage')
                doRepeat = event.key == K_r;
                print doRepeat
                return False
        if event.key in lbuttons:
            if (stagename =="SubjectChoice" or stagename=="ComputerChoice") and canRespond:
                if isChoiceBlock:
                    writeChoice(roundnum,'L')
                    subjChoice = 0
                    return False
                else:
                    if lchoice.selected:
                        confirmed = True
                        writeQueue(roundnum, 'Choice confirmation')
                    else:
                        confirmed=False
                        writeQueue(roundnum, 'Wrong choice')
                    return False         
            else:
                writeQueue(roundnum,'Choice uncaught')
                
            # if not isChoiceBlock and stagename == "SubjectChoice" and canRespond:
            #     if subjChoice == 0:
            #         writeQueue(round, 'ChoiceConfirmation')
            #         confirmed = True
            #         return False
            #     else:
            #         writeQueue(round, 'WrongChoice')
            #         confirmed = False
            #         return False
            # elif stagename =="SubjectChoice" and canRespond:
            #     writeChoice(roundnum,'L')
            #     subjChoice = 0
            #     return False
            # else:
            #     writeQueue(roundnum,'Choice uncaught')

        elif event.key in rbuttons:
            if canRespond and (stagename =="SubjectChoice" or stagename=="ComputerChoice"):
                if isChoiceBlock:
                    writeChoice(roundnum,'R')
                    subjChoice = 1
                    return False
                else:
                    if rchoice.selected:
                        confirmed = True
                        writeQueue(roundnum, 'Choice confirmation')
                    else:
                        confirmed =False
                        writeQueue(roundnum, 'Wrong choice')
                    return False                
            else:
                writeQueue(roundnum,'Choice uncaught')
            # if not isChoiceBlock and stagename == "SubjectChoice" and canRespond:
            #     if subjChoice == 1:
            #         writeQueue(round, 'ChoiceConfirmation')
            #         confirmed = True
            #         return False
            #     else:
            #         writeQueue(round, 'WrongChoice')
            #         confirmed = False
            #         return False
            # elif stagename =="SubjectChoice" and canRespond:
            #     writeChoice(roundnum,'R')
            #     subjChoice = 1
            #     return False
            # else:
            #     writeQueue(roundnum,'Choice uncaught')
        if event.key == K_F1 or event.key == K_f:
            pygame.display.toggle_fullscreen()
        if event.key == K_ESCAPE:
            print "Testing"
            pygame.event.post(pygame.event.Event(QUIT))
    return True


def wait_old(time_to_wait):
    """ waits a certain amount of time before game continues while keeping track of events. Uses a lot of CPU """
    global subjChoice
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
    wait_old(time_to_wait)

class CSVLine:
    """ For outputting events. """
    def __init__(self, newstuff):
        self.stuff = { "Round" : roundnum,
                       "Time" : time.time() - StartTime }
        self.stuff.update(newstuff)
        
    def out(self):
        preOut = [self.stuff.get(var, None) for var in theOrder]
        return  [str(var) if var != None else None for var in preOut]

def writeQueue(roundnum,message):
    """Writes a timestamped row in the log file with message."""
    now = time.time()
    print message + " logged at " + str(now)
    cline = CSVLine({"Event" : message})
    TimeStamp.writerow(cline.out())
    TimeFile.flush()


def writeChoice(roundnum,choice):
    global lchoice, rchoice, totalprofit
    """Writes a timestamped row in the log file with message."""
    now = time.time()
    print "Subject choice logged at " + str(now)
    profitEarned = 0
    safeOrRisk = "None"
    if choice is not 'T':
        profitEarned = lchoice.profit if choice == 'L' else rchoice.profit
        totalprofit += profitEarned
        pickedchoice = lchoice if choice == 'L' else rchoice
        safeOrRisk = "Risk" if pickedchoice.isRisk else "Safe"
    eventstring = "Chose" if isChoiceBlock else "Computer Chose"
    cline = CSVLine(dict({ "Event" : eventstring,
                           "Choice" : choice,
                           "RiskyOrSafeChoice" : safeOrRisk,
                           "Profit" : profitEarned,
                           "TotalProfit" : totalprofit}.items() +
                         rounds_list[roundnum].dictOut().items()))
    print rounds_list[roundnum].dictOut().items()
    TimeStamp.writerow(cline.out())
    TimeFile.flush()

def rotatePolygon(polygon, theta):
    """Rotates the given polygon which consists of corners represented as (x,y),
    around the ORIGIN, clock-wise, theta degrees"""
    theta = math.radians(theta)
    rotatedPolygon = []
    for corner in polygon :
        rotatedPolygon.append(( corner[0]*math.cos(theta)-corner[1]*math.sin(theta) , corner[0]*math.sin(theta)+corner[1]*math.cos(theta)) )
    return rotatedPolygon

def initialize(leftkey, rightkey, choicetime):
    """Initialize the windowing system as well as variables needed to run the game.
    Initialize fonts.
    This should only be called once in the main program. """
    global StartTime, mainscreen, screen, font, smallfont, luckyObj, scaledLuckyObj
    global personObj, crossObj, lilpersonObj, lilcrossObj
    global wheelObjs, scaledWheelObjs, arrowObjs, scaledArrowObjs, centerdotObj
    global pausedRound
    global sounds
    global lbuttons, rbuttons, lbuttonName, rbuttonName
    global choiceTime
    global pauseScreen
    global ends, triangles, angles

    lbuttons = [ord(leftkey)]
    if ord(leftkey) >= ord("0") and ord(leftkey) <= ord("9"):
        lbuttons.append(K_KP0 + ord(leftkey) - ord("0"))
    rbuttons = [ord(rightkey)]
    if ord(rightkey) >= ord("0") and ord(rightkey) <= ord("9"):
        rbuttons.append(K_KP0 + ord(rightkey) - ord("0"))
    lbuttonName = leftkey
    rbuttonName = rightkey

    choiceTime = choicetime
    pygame.init()
    pygame.mixer.init()
    clock = pygame.time.Clock()
    StartTime = time.time()
    if fullScreen:
        mainscreen = pygame.display.set_mode((width, height), FULLSCREEN)
    else:
        mainscreen = pygame.display.set_mode((width, height), HWSURFACE | DOUBLEBUF | RESIZABLE)
    pygame.display.set_caption('Gamble game')
    pygame.mouse.set_visible(0)
    font = pygame.font.SysFont(None, 47)
    smallfont = pygame.font.SysFont(None, 20)
    luckyObj = [pygame.image.load('data/lucky-slots.png'), pygame.image.load('data/lucky-slots.png')]
    scaledLuckyObj = [pygame.transform.scale(i, (256,256)) for i in luckyObj]
    wheelObjs = [pygame.image.load('data/chart{0}.png'.format(11-i)) for i in range(1,12)]
    arrowObjs = [pygame.image.load('data/arrow{0}.png'.format(10-i)) for i in range(11)]
    scaledWheelObjs = [pygame.transform.smoothscale(i, (200, 200)) for i in wheelObjs]
    scaledArrowObjs = [pygame.transform.smoothscale(i, (210, 210)) for i in arrowObjs]
    centerdotObj = pygame.image.load('data/centerdot.png')
    #arrowObj = pygame.image.load('data/arrow200.png')

    personObj = pygame.image.load('data/personal123.png')
    crossObj = pygame.image.load('data/cross.png')
    personObj = pygame.transform.smoothscale(personObj, (targetsize,targetsize))
    crossObj = pygame.transform.smoothscale(crossObj, (targetsize,targetsize))
    lilpersonObj = pygame.image.load('data/personal123.png')
    lilpersonObj = pygame.transform.smoothscale(lilpersonObj, (liltargetsize, liltargetsize))
    lilcrossObj = pygame.transform.smoothscale(crossObj, (liltargetsize, liltargetsize))
    screen = pygame.Surface((800, 600), pygame.SRCALPHA, 32)
    pauseScreen = screen.copy()
    # Sounds by Tim Gormley
    sounds = [pygame.mixer.Sound(x) for x in ["data/win.ogg", "data/lose.ogg", "data/chaching.ogg"]]

    zeroend = (0, -radius)
    zerotriangle = [(0, -radius), (-3, -radius+5), (3, -radius+5)]
    angles = [-(i*2*pi/11 + 2*pi/22) for i in range(11)]
    ends = [rotateDot(zeroend, theta) for theta in angles]
    triangles = [rotatePolygon(zerotriangle, theta) for theta in angles]

def rotateDot(dot, theta):
    return ( dot[0]*math.cos(theta) - dot[1]*math.sin(theta), dot[0]*math.sin(theta) + dot[1]*math.cos(theta))

def rotatePolygon(polygon, theta):
    """Rotates the given polygon which consists of corners represented as (x,y),
    around the ORIGIN, CLOCK-WISE, theta degrees"""
    #theta = math.radians(theta)
    rotatedPolygon = []
    for corner in polygon :
        rotatedPolygon.append(( corner[0]*math.cos(theta)-corner[1]*math.sin(theta) , corner[0]*math.sin(theta)+corner[1]*math.cos(theta)) )
    return rotatedPolygon

def flipupdate(black = 0):
    global screen, mainscreen, size
    if black:
        blackbox(black)
    mainscreen.blit(pygame.transform.smoothscale(screen,size),(0,0))
    pygame.display.flip()

def roundSetup(thefile, SID, numChoiceRounds=1000,  numNoChoiceRounds = 1000, practice=False, ChoiceFirst=True, noPassive=True):
    """ Load everything necessary to run the game.
    Load the rounds.
    Set up the data file to write to. """
    global timing, roundnum, nrounds, nrounds2, rounds_list, rounds_list2, choiceTime, isPractice, ID
    global isChoiceBlock, isFirstRun, noPassiveBlock
    global roundtype

    rounds_list = readInfo(thefile, numChoiceRounds)
    #rounds_list_non = readInfo(thefile, numChoiceRounds, 'non-social')
    #rounds_list = rounds_list_social + rounds_list_non

    #random.shuffle(rounds_list)


    rounds_list2 = readInfo(thefile, numNoChoiceRounds)
    #rounds_list_non2 = readInfo(thefile, numNoChoiceRounds, 'non-social')
    #rounds_list2 = rounds_list_social2 + rounds_list_non2

    #random.shuffle(rounds_list2)

    isPractice = practice
    nrounds = len(rounds_list)
    setupWriters(SID, practice)
    roundnum = 0
    isChoiceBlock = ChoiceFirst
    isFirstRun = True
    noPassiveBlock=noPassive
    
    timing = {"NewRound" : random.uniform(1000,1000)/speedup,
              "GamePresent": random.uniform(500,500)/speedup,
              "ChoicePresentation" : random.uniform(500,500)/speedup,
              "SubjectChoice" : (choiceTime * 1000)/speedup,
              "ChoiceConfirmation" : random.uniform(500,750)/speedup,
              "Reveal" : random.uniform(500,750)/speedup,
              "PausedScreen" : 10800000}



def instructions():
    # Instructions
    message(["Gambling Task",
              "",
              "Press return to move through the slides."])

    # message(["The following task is a gambling task.",
    #     "In each questions, you will be asked",
    #     "to make decisions for money."])

    # # Explain social/non-social
    # message(["There will be two different types of task.",
    #     "",
    #     "Depending on the type, you will be either",
    #     "allowed to keep the money you earned",
    #     "or asked to donate the money to charity.",
    #     "",
    #     "They will be __ by different icons."])

    # # Non-Social
    # whiteOut()
    # screen.blit(lilpersonObj, ((width-liltargetsize)/2, (height-liltargetsize)/2-90))
    # writeMultipleLines(["When you see the icon above,",
    #     "you will get to keep", "the money you earn."], center=(width/2, (height+liltargetsize)/2+10))
    # flipupdate()
    # wait(timing["PausedScreen"])

    # # Social
    # whiteOut()
    # screen.blit(lilcrossObj, ((width-liltargetsize)/2, (height-liltargetsize)/2-90))
    # writeMultipleLines(["When you see the icon above,",
    #     "the money you earn", "will be donated to charity."], center=(width/2, (height+liltargetsize)/2+10))
    # flipupdate()
    # wait(timing["PausedScreen"])

    # message(["Now, let us go through ___."])

    for path in sorted(glob.glob("data/instructions-*.png")):
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

    # message(["Press {0} or left click to choose".format(lbuttonName),
    #          "the bet on the left",
    #          "",
    #          "Press {0} or right click to choose".format(rbuttonName),
    #          "the bet on the right",
    #          "",
    #          "Click or Press ENTER to continue"])

    # message(["You have {0:.1f} seconds to".format(timing["SubjectChoice"]/1000.0),
    #          "make a decision in each round.",
    #          "",
    #          "If you do not make a decision",
    #          "the borders will turn red",
    #          "and you will earn nothing",
    #          "for that round.",
    #          "",
    #          "Click or Press ENTER to continue"])

    #displayImage("data/prompt-practice.png")
    
def main(doInstructions=True):
    """ Main loop. Runs the game after you've initialized variables and rounds. """
    global running, canRespond, stagename, totalprofit
    global subjChoice, totalprofit
    global roundnum, rounds_list, nrounds, winlose, confirmed
    global lchoice, rchoice
    global isPractice, isFirstRun, isChoiceBlock, noPassiveBlock
    global didInit
    global targetObj, liltargetObj
    global cur_type

    lchoice = Choice((width/2 - width/4 -20, height/2 - 20), (width/3 + 20, height - 100 -100))
    rchoice = Choice((width/2 + width/4 + 20, height/2 - 20), (width/3 + 20, height - 100 -100))

    running = True
    canRespond = False
    stagename = "GameStart"

    totalProfit = 0

#Create The Backgound
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill((250, 250, 250))

    if doInstructions:
        instructions()

    if not isChoiceBlock:
        message(['In the next '+str(nrounds)+' choices', 
                'the computer will make a choice',
                'and your task is to just confirm',
                'by clicking the selected option.', 
                "",
                'Click or Press ENTER to continue.'])
        message(['You will get a $10 penalty', 
            'when you fail to confirm', 'the right choice',
            'by clicking the selected option.',
            "",
            'Click or Press ENTER to continue.'])
    else:
        message(['In the next '+str(nrounds)+' choices (self/charity),',
                'select whether you want to bet for $30',
                'or ','keep the $10 prize.',
                "",
                'Click or Press ENTER to continue.'])

    # Main Loop
    while running:

        #
        # Choice block
        #
        if isChoiceBlock:
            # 
            # Block slide: Self/Social
            

            # 
            cur_round = rounds_list[roundnum]
            cur_type = cur_round.roundtype # social/non-social
            pre_cur_type=rounds_list[roundnum-1].roundtype if roundnum>=1 else "First Trial"

            if pre_cur_type != cur_type:
                screen.blit(background, (0, 0))
                canRespond = False
                #stagename = "Target Display"
                targetObj = personObj if cur_type == "Self" else crossObj
                liltargetObj = lilpersonObj if cur_type == "Self" else lilcrossObj
                #whiteOut()
                screen.blit(targetObj, ((width-targetsize)/2, (height-targetsize)/2 - 30))
            
                targetMsg = "Playing for Self" if cur_type == "Self" else "Playing for Charity"
            
                writeOneLine(targetMsg, (width/2, (height+targetsize)/2), pygame.font.Font(None, 50))
                writeQueue(roundnum, "NewRound Target: "+cur_type)
                #flipupdate()
                flipupdate()
                wait(timing["NewRound"])
                #flipupdate()
                #screen.blit(background, (0, 0))
                #flipupdate()



            # First slide: Fixation
            stagename = "NewRound"
            print "Round number " + str(roundnum+1)
            screen.blit(background, (0, 0))
            rw, rh = 10, 100
            pygame.draw.rect(screen, (0, 0, 0), (width/2 - rw/2, height/2-rh/2, rw, rh))
            pygame.draw.rect(screen, (0, 0, 0), (width/2 - rh/2, height/2-rw/2, rh, rw))
            new_round_text = font.render("New round", True, (200,0,0))
            #screen.blit(new_round_text, (270, 260))
            flipupdate()
            writeQueue(roundnum,"NewRound")
            jiggle = random.choice([0, 50, 100, 150, 200, 250])
            wait(timing["NewRound"])
            screen.blit(background, (0, 0))
            whiteOut()
            flipupdate()

            #cur_round = rounds_list[roundnum]
            #cur_type = cur_round.roundtype # social/non-social
            
            #
            # Target Display: social/non-social (Can't respond)
            #  First Slide With Target
            stagename = "NewRound"
            print "Round number " + str(roundnum+1)

            
            # 
            # Second slide: Display choices (Can't respond)
            # 
            canRespond = False
            stagename = "ChoicePresentation"
            lchoice.update(cur_round, 0)
            rchoice.update(cur_round, 1)
            whiteOut()
            lchoice.draw()
            rchoice.draw()


            # 
            # Third slide: SubjectChoice
            # 
            canRespond = True
            stagename = "SubjectChoice"
            subjChoice = None
            lchoice.bordercolor = readycolor         # Yellow border
            rchoice.bordercolor = readycolor
            whiteOut()
            lchoice.draw()
            rchoice.draw()
            writeQueue(roundnum,"SubjectChoice")
            flipupdate(0)
            wait(timing["SubjectChoice"])


            #
            # Fourth slide: Choice confirmation
            #
            lchoice.bordercolor = None
            rchoice.bordercolor = None
            if subjChoice is None:
                lchoice.bordercolor = noselectcolor
                rchoice.bordercolor = noselectcolor
                writeChoice(roundnum, 'T')
            stagename = "ChoiceConfirmation"
            if subjChoice == 0:
                lchoice.selected = True
            elif subjChoice == 1:
                rchoice.selected = True
            whiteOut()
            lchoice.draw()
            rchoice.draw()
            writeQueue(roundnum,"ChoiceConfirmation")
            flipupdate()
            jiggle = random.choice([0, 50, 100, 150, 200, 250])
            wait(timing["ChoiceConfirmation"])

            #
            # Fifth slide: Reveal
            #
            stagename = "Reveal"
            bluecolor = (0, 0, 255)
            if subjChoice == 0:
                lchoice.color = bluecolor
            else:
                rchoice.color = bluecolor
            whiteOut()
            lchoice.reveal()
            rchoice.reveal()
            lchoice.draw()
            rchoice.draw()
            writeQueue(roundnum,"Reveal")
            flipupdate()
            if subjChoice is not None:
                sounds[winlose].play()
            wait(timing["Reveal"])


        #
        # No-choice block
        #
        else:
            # 
            # First slide: Fixation
            # 
            stagename = "GamePresent"
            print "Round number " + str(roundnum)
            screen.blit(background, (0, 0))
            rw, rh = 10, 100
            pygame.draw.rect(screen, (0, 0, 0), (width/2 - rw/2, height/2-rh/2, rw, rh))
            pygame.draw.rect(screen, (0, 0, 0), (width/2 - rh/2, height/2-rw/2, rh, rw))
            flipupdate()
            writeQueue(roundnum,"GamePresent")
            jiggle = random.choice([0, 50, 100, 150, 200, 250])
            wait(timing["GamePresent"])

            #whiteOut()
            #flipupdate()


            #
            # Target Display: social/non-social (Can't respond)

            
            stagename = "NewRound"
            print "Round number " + str(roundnum)
        
            cur_round = rounds_list[roundnum]
            cur_type = cur_round.roundtype # social/non-social
            screen.blit(background, (0, 0))

            canRespond = False

        
            targetObj = personObj if cur_type == "Self" else crossObj
            liltargetObj = lilpersonObj if cur_type == "Self" else lilcrossObj
            screen.blit(targetObj, ((width-targetsize)/2, (height-targetsize)/2 - 30))
            targetMsg = "Playing for Self" if cur_type == "Self" else "Playing for Charity"
            writeOneLine(targetMsg, (width/2, (height+targetsize)/2), pygame.font.Font(None, 50))
            writeQueue(roundnum, "NewRound Target: "+cur_type)
            flipupdate()
            wait(timing['NewRound'])


            # 
            # Second slide: Display choices (Can't respond)
            # 
            canRespond = False
            stagename = "ChoicePresentation"
            lchoice.update(cur_round, 0)
            rchoice.update(cur_round, 1)
            whiteOut()
            lchoice.draw()
            rchoice.draw()
            flipupdate()
            wait(timing["ChoicePresentation"])


            # 
            # Third slide: SubjectChoice (subject should click to confirm within no-choice block)
            # 
            pygame.mouse.set_visible(1)
            canRespond = True
            stagename = "ComputerChoice"
            subjChoice = random.choice([0, 1])
            if subjChoice == 0:
                lchoice.selected = True
            elif subjChoice == 1:
                rchoice.selected = True
            confirmed = False
            lchoice.draw()
            rchoice.draw()
            writeQueue(roundnum,"ComputerChoice")
            leftright = 'L' if lchoice.selected else 'R'
            writeChoice(roundnum, leftright)
            flipupdate()
            wait(timing["SubjectChoice"])
            pygame.mouse.set_visible(0)


            #
            # Fourth slide: Choice confirmation
            #
            stagename="SubjectChoice"
            if not confirmed:
                lchoice.penalty()
                rchoice.penalty()
            # lchoice.bordercolor = wrongcolor if not confirmed else None
            # rchoice.bordercolor = wrongcolor if not confirmed else None
            lchoice.draw()
            rchoice.draw()
            writeQueue(roundnum,"ChoiceConfirmation")
            flipupdate()
            jiggle = random.choice([0, 50, 100, 150, 200, 250])
            wait(timing["ChoiceConfirmation"])


            #
            # Fifth slide: Reveal
            #
            stagename = "Reveal"
            bluecolor = (0, 0, 255)
            if subjChoice == 0:
                lchoice.color = bluecolor if confirmed else wrongcolor
            else:
                rchoice.color = bluecolor if confirmed else wrongcolor
            whiteOut()
            lchoice.reveal()
            rchoice.reveal()
            lchoice.draw()
            rchoice.draw()
            writeQueue(roundnum,"Reveal")
            flipupdate()
            if subjChoice is not None:
                sounds[winlose].play()
            wait(timing["Reveal"])


        #
        # For both choice/no-choice blocks
        #
        if pausedRound and roundnum == pausedRound:
            message(["Paused", "Please wait for experimenter", "to press Return"])
            pause()

        # Game done
        roundnum = roundnum + 1
        if roundnum >= nrounds:
            # if the first run
            if isFirstRun and (not noPassiveBlock):
                roundnum = 0
                rounds_list = rounds_list2
                nrounds = len(rounds_list2)
                isChoiceBlock = not isChoiceBlock
                isFirstRun = False

                if not isChoiceBlock:
                    message(['In the next '+str(nrounds)+' choices', 
                            'the computer will make a choice',
                            'and your task is to just confirm',
                            'by clicking the selected option.',
                            "",
                            'Click or Press ENTER to continue.'])
                    message(['You will get a $10 penalty', 
                        'when you fail to confirm', 'the right choice',
                        'by clicking the selectred option.',
                        "",
                        'Press ENTER to start.'])
                else:
                    isFirstRun=False
                    running=False
                    message(['In the next '+str(nrounds)+' choices, select',
                            'whether you want to bet for $30',
                            'or', 'keep the $10 prize.',
                            "",
                            'Click or Press ENTER to continue.'])
            # if not the first run
            else:
                screen.blit(background, (0, 0))
                if not isPractice:
                    writeMultipleLines(["Game complete",
                                        "You did better than",
                                        "{0:.0f}% ".format(percentile(totalprofit)),
                                        "of people who played",
                                        "this game.",
                                        "Congratulations!"])
                    flipupdate()
                    stagename = "PausedScreen"
                    wait(timing["PausedScreen"])
                    print "Game complete"
                running = False

def percentile(myscore):
    others = [2175, 2675, 2780, 2805, 2500, 1160, 2385, 2670, 2295]
    def doiwin(x):
        return myscore > x
    return len(filter(doiwin, others)) * 100.0 / len(others)

def pauseInterrupt():
    global stagename, screen, timing, pauseScreen
    # whiteOut()
    paused_text = font.render("Paused by experimenter", True, (0,0,0))
    prect = paused_text.get_rect()
    prect.center = screen.get_rect().center
    pauseScreen.blit(screen, (0, 0))
    pygame.draw.rect(screen, (150, 150, 150), prect)
    screen.blit(paused_text, prect)
    writeQueue(round,"PauseBegin")
    flipupdate()

def pauseEnd():
    global pauseScreen
    whiteOut()
    screen.blit(pauseScreen, (0, 0))
    flipupdate()
    writeQueue(round,"PauseEnd")

def pause():
    global stagename, screen, timing
    whiteOut()
    paused_text = font.render("Waiting for Scanner", True, (0,0,0))
    prect = paused_text.get_rect()
    prect.center = screen.get_rect().center
    screen.blit(paused_text, prect)
    stagename = "PausedScreen"
    writeQueue(roundnum,"PausedScreen")
    flipupdate()
    wait(timing["PausedScreen"])

def writeMultipleLines(listOlines, underline = -1, center = (width/2, height/2)):
    global font

    writeMultipleLinesHelper(listOlines, center, font, underline = -1)

def writeMultipleLinesHelper(listOlines, center, thefont, underline = -1, color = (0, 0, 0), bottom = False):
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

def writeOneLine(msg, center, thefont, color = (0, 0, 0)):
      msgSurfaceObj = thefont.render(msg, True, color)
      msgRectobj = msgSurfaceObj.get_rect()
      msgRectobj.center = center
      screen.blit(msgSurfaceObj, msgRectobj)

def blackbox(black = 1):
    size = 70
    size2 = 70
    pygame.draw.rect(screen, (255, 255, 255), (0, height - size2, size2, size2))    
    color = (0, 0, 0) if black else (255, 255, 255)
    pygame.draw.rect(screen, color, (0, height - size, size, size))    

def whiteOut():
    background = pygame.Surface(screen.get_size())
    background = background.convert()
    background.fill((250, 250, 250))
    screen.blit(background, (0, 0))

def displayImage(filepath, stage="Message"):
    global stagename, screen, timing
    stagename = stage
    whiteOut()
    map_surface = pygame.image.load(filepath).convert_alpha()
    surface2 = pygame.transform.smoothscale(map_surface, (width, height))
    screen.blit(surface2, (0,0)) 
    writeQueue(roundnum,stage)
    flipupdate()
    wait(timing["PausedScreen"])

# def promptRepeat():
#     global stagename, screen, timing, doRepeat, roundnum
#     displayImage("data/experimenter-prompt-26.png", "Repeat")
#     if doRepeat:
#         roundnum = 0
#         main(doInstructions=False)
#         promptRepeat()


def promptRepeat():
    global stagename, screen, timing, doRepeat, roundnum

    message(["Experimenter: press 'r' to repeat",
             "                   the practice rounds.",
             "",
             "Press spacebar or return to continue to the task."], "Repeat")
    print "After message"

    if doRepeat:
        roundnum = 0
        main(doInstructions=False)
        promptRepeat()

    print "Done"

def message(listOlines, stage = "Message"):
    global stagename, screen, timing
    stagename = stage
    whiteOut()
    writeMultipleLines(listOlines)
    writeQueue(roundnum, stage)
    flipupdate()
    wait(timing["PausedScreen"])


#this calls the 'main' function when this script is executed
if __name__ == '__main__':
    print "DO NOT RUN DIRECTLY. USE GAMBLE_RUN"
