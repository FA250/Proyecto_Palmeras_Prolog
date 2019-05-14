% distancias entre palmeras
palm2palm(jasmine,sheherazade,18).
palm2palm(sheherazade,nina,12).
palm2palm(jasmine,nina,19).
palm2palm(elisa,nina,8).
palm2palm(elisa,sheherazade,20).

% distancias entre una palmera y el pozo
palm2well(jasmine,13).
palm2well(sheherazade,19).
palm2well(nina,22).
palm2well(elisa,34).

% cantidad de agua por palmera
:- dynamic(palm_needs/2).
palm_needs(jasmine,2).
palm_needs(sheherazade,1).
palm_needs(nina,2).
palm_needs(elisa,4).

% tamaño del balde
bucket(5).

update(Palm, Water):- palm_needs(Palm,X), X\=0, X-Water>=0, Y is X-Water, updateAux(palm_needs(Palm,X), palm_needs(Palm,Y)).

updateAux(PalmBefore, PalmAfter) :- retract(PalmBefore), assertz(PalmAfter).