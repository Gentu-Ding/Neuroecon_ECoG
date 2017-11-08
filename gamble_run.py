#!/usr/bin/env python
# Social Gamble Game
# Weilun Ding & Joshua Moller-Mara, 2014-2017

import Gamble_Lib
from Tkinter import *
import Tkinter as ttk
from ttk import *
 
root = Tk()
root.title("Tk dropdown example")
 
# Add a grid
mainframe = Frame(root)
mainframe.grid(column=0,row=0, sticky=(N,W,E,S) )
mainframe.columnconfigure(0, weight = 1)
mainframe.rowconfigure(0, weight = 1)
mainframe.pack(pady = 100, padx = 100)
 
# Create a Tkinter variable
tkvar = StringVar(root)
 
# Dictionary with options
choices = { 'Ming','Anna','Ignacio','Zhihao','Gil','Nick','Weilun','Not listed'}
#tkvar.set('Ming') # set the default option
 
popupMenu = OptionMenu(mainframe, tkvar, *choices)
Label(mainframe, text="Choose the Experimenter").grid(row = 1, column = 1)
popupMenu.grid(row = 2, column =1)
 
# on change dropdown value
#def change_dropdown(*args):
    #print( tkvar.get() )
 
# link function to change dropdown
#tkvar.trace('w', change_dropdown)
 

def rquit():
    global root
    root.quit()
    
ttk.Button(root, text='Submit', command=root.destroy).pack(side=ttk.RIGHT)    
root.mainloop()
#root.after()
experimenter=tkvar.get()
print(experimenter)

donePrompting = False

def defaultInput(string, default, typefunc):
    value = raw_input(string)
    if not value:
        return default
    return typefunc(value)

while not donePrompting:
    choiceTime = defaultInput("How much time should subjects have to make a decision? (default=4s): ", 4, float)
    keyLeft = defaultInput("What button do you want to use for LEFT choice? (default = 1): ", "1", str)
    keyRight = defaultInput("What button do you want to use for RIGHT choice?  (default = 3): ", "3", str)
    SID = defaultInput("Please enter an ID: ", "0", str)

    donePrompting = defaultInput("""\n\nSubjects have {time}s to make a decision
'Right' mapped to {rightkey} key
'Left' mapped to {leftkey} key
Subject ID is {sid}
Ok to begin experiment? y/n: """.format(time=choiceTime,
                                        rightkey=keyRight,
                                        leftkey=keyLeft,
                                        sid=SID), "y", str) == "y"


# Include the Passive Block or Not (True for NOT including)
noPassiveBlock=True

# Practiced
numrounds_choice = 6
numrounds_nochoice = 1
ChoiceFirst = True


Gamble_Lib.initialize(keyLeft, keyRight, choiceTime,experimenter)
Gamble_Lib.roundSetup("data/gamble_practice_new.csv", SID, numrounds_choice, numrounds_nochoice, True, ChoiceFirst,noPassiveBlock)
Gamble_Lib.main(doInstructions=False)
Gamble_Lib.promptRepeat()

numrounds_choice = 2
numrounds_nochoice = 2
ChoiceFirst = True

# No choice block
Gamble_Lib.roundSetup("data/gamble_choices_new.csv", SID, numrounds_choice, numrounds_nochoice, False, ChoiceFirst, noPassiveBlock)
Gamble_Lib.main(doInstructions=False)

