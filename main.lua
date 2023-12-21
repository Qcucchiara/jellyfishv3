io.stdout:setvbuf("no")

--variables
math.randomseed(love.timer.getTime())

hero = {}
ennemie = {}
detritus = {}
liste_sprite = {}
liste_ennemie = {}
liste_detritus = {}
liste_pPoisson = {}
largeur,
    hauteur,
    fond,
    score,
    sndMusicTouche,
    sndMusiqueJeu,
    imgMenu,
    imgGameover,
    imgJeu,
    gameOver,
    frame,
    inclinaison,
    timer,
    cdp1,
    cdp2,
    drift,
    taillePPY,
    tailleGlobale = nil
ecran_courant = "menu"

function math.dist(x1, y1, x2, y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

-- création sprites généralisé, permet d'assigner les variables génériques a tout les sprites.
function CreeSprite(pX, pY, pNomImage, pSpeed, pScaleX, pScaleY, vie, pRota, pDrift)
    sprite = {}
    sprite.x = pX
    sprite.y = pY
    sprite.image = love.graphics.newImage("images/" .. pNomImage .. ".png")
    sprite.h = sprite.image:getHeight()
    sprite.l = sprite.image:getWidth()
    sprite.speed = pSpeed
    sprite.supprime = false
    sprite.valeur = 0
    sprite.scaleX = pScaleX
    sprite.scaleY = pScaleY
    sprite.hit = false
    sprite.drift = pDrift
    sprite.vie = vie
    sprite.rota = pRota

    table.insert(liste_sprite, sprite)
    return sprite
end

-- précision du type d'ennemie et ses coordonnées X Y.
function CreeEnnemie()
    pType = math.random(1, 5)
    pY = math.random(50, hauteur - 100)
    nomImage = " "
    valeur = 0

    if pType == 1 then
        nomImage = "requin_1"
        speed = 6
        inclinaison = 0
    end

    if pType == 2 then
        nomImage = "tortue_1"
        speed = 2
        inclinaison = 0
    end

    if pType == 3 then
        nomImage = "poisson_1"
        speed = 3
        inclinaison = 0
    end

    if pType == 4 then
        nomImage = "pieuvre_1"
        speed = 3
        inclinaison = 45
    end

    if pType == 5 then
        nomImage = "anguille_1"
        speed = 4
        inclinaison = 0
    end
    local flippendo = math.random(0, 1)
    if flippendo == 0 then
        sens = -1
        inclinaison = -inclinaison
        pX = largeur + sprite.l
    else
        sens = 1
        pX = 0 - sprite.l
    end
    local drifto = math.random(0, 1)
    if drifto == 0 then
        drift = false
    else
        drift = true
    end
    --pour utiliser la fonction CreeSprite
    ennemie = CreeSprite(pX, pY, nomImage, speed, sens, 1, 0, inclinaison, drift)

    table.insert(liste_ennemie, ennemie)
end

function CreeDetritus()
    pType = math.random(1, 7)
    pX = math.random(50, largeur - 50)
    pY = -100
    nomImage = " "
    valeur = 0

    if pType == 1 then
        nomImage = "bierre"
        valeur = 50
    end

    if pType == 2 then
        nomImage = "bocal"
        valeur = 50
    end

    if pType == 3 then
        nomImage = "bouteille_1"
        valeur = 100
    end

    if pType == 4 then
        nomImage = "cannette"
        valeur = 50
    end

    if pType == 5 then
        nomImage = "coca"
        valeur = 70
    end

    if pType == 6 then
        nomImage = "conserve_1"
        valeur = 80
    end

    if pType == 7 then
        nomImage = "conserve_2"
        valeur = 90
    end

    detritus = CreeSprite(pX, pY, nomImage)

    detritus.valeur = valeur

    table.insert(liste_detritus, detritus)
end

function CreeBandDePPoisson() --nombre aléatoire entre ~7 et ~15
    --ajouter ça plus tard
    pX = math.random(-200, -10)
    pY = math.random(350, hauteur - 100)
    scaleX = (math.random(5, 10)) / 10
    scaleY = (math.random(5, 10)) / 10
    nomImage = "Ppoisson_1"
    pRota = 0
    local drifto = math.random(0, 1)
    if drifto == 0 then
        drift = false
    else
        drift = true
    end
    pPoisson = CreeSprite(pX, pY, nomImage, 2.5, scaleX, scaleY, 0, pRota, drift)

    table.insert(liste_pPoisson, pPoisson)
end

function DemarreJeu()
    --initialiser le score
    score = 0
    cdp1 = 0
    cdp2 = 0
    timer = 0
    fullscreen = true
    love.window.setFullscreen(fullscreen)
    --création de détritus
    InitDetritus()
    --création d'ennemies
    --Crée entre 1 et 4 ennemie au démarrage
    InitEnnemie(1, 4)
    --créattion bandDePoisson
    InitPPoisson()
    --création du hero
    hero = CreeSprite(700, 600, "meduse_1", 2.5, 1, 1, 5)
    hero.l = 48
    hero.h = 48
    hero2 = CreeSprite(900, 600, "meduse_2", 2.5, 1, 1, 5)
    hero2.l = 48 -- la largeur était a 47 de base
    hero2.h = 48 --c'est fine maintenant
end

function InitEnnemie(min, max)
    --
    nbEnnemie = math.random(min, max)

    while (nbEnnemie > 0) do
        CreeEnnemie()
        nbEnnemie = nbEnnemie - 1
    end
end

function InitDetritus()
    nbDetritus = math.random(1, 5)

    while (nbDetritus > 0) do
        CreeDetritus()
        nbDetritus = nbDetritus - 1
    end
end

function InitPPoisson()
    nbPPoisson = math.random(3, 9)

    while (nbPPoisson > 0) do
        CreeBandDePPoisson()
        nbPPoisson = nbPPoisson - 1
    end
end

function love.load()
    gameOver = false
    timer = 0
    --mettre un titre
    love.window.setTitle("Jellyfish stories by DTI Chambéry")
    --initialiser le son
    sndMusicTouche = love.audio.newSource("son/toucheDetritus.wav", "static") -- pour l'enregistrer dans la mémoire
    sndMusicTouche:setVolume(0.5)
    sndMusicJeu = love.audio.newSource("son/techy.mp3", "stream") -- pour la streamer et ne pas l'enregistrer dans la mémoire
    sndMusicJeu:setVolume(0.1)
    sndMusicJeu:setLooping(true) -- pour que la musique et permet de faire boucler
    --chargement variables et précisions de ces dernières
    imgMenu = love.graphics.newImage("images/ecran_titre.png")
    imgGameover = love.graphics.newImage("images/game_over.png")
    imgJeu = love.graphics.newImage("images/fond.png")

    fond = imgMenu

    largeur = (love.graphics.getWidth()) * 1.92
    hauteur = (love.graphics.getHeight()) * 1.435

    DemarreJeu()
end

function UpdateGameover()
    fond = imgGameover
    sndMusicJeu:stop()
end

function love.update(dt)
    if ecran_courant == "jeu" then
        if score < 0 then
            gameOver = true
            score = 0
        end
        if hero.vie <= 0 or hero2.vie <= 0 then
            gameOver = true
        end
        fond = imgJeu
        timer = timer + dt
        sndMusicJeu:play()
        -- mouvements Heros
        if love.keyboard.isDown("q") and hero.x > hero.l / 2 and math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.l then
            hero.x = hero.x - hero.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero.l and hero.x > hero2.x then --il y a une petite feature pas prévu par là (pas compris pourquoi)
            hero.x = hero.x + 1 * (60 * dt)
        end

        if
            love.keyboard.isDown("d") and hero.x < largeur - (hero.l / 2) and
                math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.l
         then
            hero.x = hero.x + hero.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero.l and hero.x < hero2.x then
            hero.x = hero.x - 1 * (60 * dt)
        end
        if love.keyboard.isDown("z") and hero.y > hero.h / 2 and math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.h then
            hero.y = hero.y - hero.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero.h and hero.y > hero2.y then
            hero.y = hero.y + 1 * (60 * dt)
        end

        if
            love.keyboard.isDown("s") and hero.y < hauteur - (hero.h / 2) and
                math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.h
         then
            hero.y = hero.y + hero.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero.h and hero.y < hero2.y then
            hero.y = hero.y - 1 * (60 * dt)
        end

        if love.keyboard.isDown("lshift") and cdp1 < 1 then
            hero.speed = 10
            cdp1 = 10
        end

        if cdp1 < 9.8 then
            hero.speed = 2.5
        end
        if cdp1 > 1 then
            cdp1 = cdp1 - dt
        end
        -------------------------------------------------------------------------hero 2
        if
            love.keyboard.isDown("left") and hero2.x > 0 + hero2.l / 2 and
                math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.l
         then
            hero2.x = hero2.x - hero2.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero2.l and hero2.x > hero.x then
            hero2.x = hero2.x + 1 * (60 * dt)
        end

        if
            love.keyboard.isDown("right") and hero2.x < largeur - (hero2.l / 2) and
                math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.l
         then
            hero2.x = hero2.x + hero2.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero2.l and hero2.x < hero.x then
            hero2.x = hero2.x - 1 * (60 * dt)
        end
        if
            love.keyboard.isDown("up") and hero2.y > 0 + hero2.h / 2 and
                math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.h
         then
            hero2.y = hero2.y - hero2.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero2.h and hero2.y > hero.y then
            hero2.y = hero2.y + 1 * (60 * dt)
        end

        if
            love.keyboard.isDown("down") and hero2.y < hauteur - (hero2.h / 2) and
                math.dist(hero.x, hero.y, hero2.x, hero2.y) > hero.h
         then
            hero2.y = hero2.y + hero2.speed * (120 * dt)
        elseif math.dist(hero.x, hero.y, hero2.x, hero2.y) < hero2.h and hero2.y < hero.y then
            hero2.y = hero2.y - 1 * (60 * dt)
        end

        if love.keyboard.isDown("rctrl") and cdp2 < 1 then
            hero2.speed = 10
            cdp2 = 10
        end

        if cdp2 < 9.8 then
            hero2.speed = 2.5
        end
        if cdp2 > 1 then
            cdp2 = cdp2 - dt
        end

        -- mouvements ennemies + colisions.
        for d = #liste_ennemie, 1, -1 do -- for "variable" = toujours position de départ, puis position d'arrivée, puis déplacement.
            local monEnnemie = liste_ennemie[d]
            if monEnnemie.scaleX == 1 then
                if monEnnemie.x < 30 then
                    monEnnemie.x = monEnnemie.x + 1 * (60 * dt)
                else
                    monEnnemie.x = monEnnemie.x + monEnnemie.speed * (60 * dt)
                end
            else
                if monEnnemie.x > largeur - monEnnemie.l - 30 then
                    monEnnemie.x = monEnnemie.x - 1 * (60 * dt)
                else
                    monEnnemie.x = monEnnemie.x - monEnnemie.speed * (60 * dt)
                end
            end
            for e = 1, #liste_ennemie, 1 do
                local autre_ennemie = liste_ennemie[e] --crochets = positions dans la liste
                if math.dist(monEnnemie.x, monEnnemie.y, autre_ennemie.x, autre_ennemie.y) < monEnnemie.h and e < d then
                    autre_ennemie.y = autre_ennemie.y + 5 * (60 * dt)
                    monEnnemie.y = monEnnemie.y - 5 * (60 * dt)
                end
            end

            if monEnnemie.drift == true and (largeur / 2) - 10 < monEnnemie.x and monEnnemie.x < (largeur / 2) + 10 then
                monEnnemie.scaleX = -monEnnemie.scaleX
                monEnnemie.rota = -monEnnemie.rota
            end
            --if monEnnemie.x < largeur then
            --monEnnemie.x = monEnnemie.x + monEnnemie.speed *(60*dt)
            --end
            if monEnnemie.x >= largeur + (monEnnemie.l * 3) then
                monEnnemie.supprime = true
                if #liste_ennemie < 5 then
                    InitEnnemie(0, 2)
                end
            elseif monEnnemie.x < 0 - monEnnemie.l * 3 then
                monEnnemie.supprime = true
                if #liste_ennemie < 5 then
                    InitEnnemie(0, 2)
                end
            end
            --collisions
            if
                math.dist(hero.x, hero.y, monEnnemie.x, monEnnemie.y) < monEnnemie.image:getWidth() / 2 and
                    monEnnemie.hit == false
             then
                hero.vie = hero.vie - 1
                monEnnemie.hit = true
            end
            ----------------------------------------------------------------------------- hero 2
            if
                math.dist(hero2.x, hero2.y, monEnnemie.x, monEnnemie.y) < monEnnemie.image:getWidth() / 2 and
                    monEnnemie.hit == false
             then
                hero2.vie = hero2.vie - 1
                monEnnemie.hit = true
            end

            if monEnnemie.hit == true then
                monEnnemie.rota = monEnnemie.rota + 0.1 * (60 * dt)
            end
        end
        --déplacement des detritus + colisions
        for c = 1, #liste_detritus, 1 do -- # signifit de prendre le dernier de la liste
            local monDetritus = liste_detritus[c]
            for b = 1, #liste_detritus, 1 do
                local autre_detritus = liste_detritus[b]
                if math.dist(monDetritus.x, monDetritus.y, autre_detritus.x, autre_detritus.y) < monDetritus.l and b < c then
                    autre_detritus.x = autre_detritus.x + 5 * (60 * dt)
                    monDetritus.x = monDetritus.x - 5 * (60 * dt)
                end
            end
            if
                math.dist(hero.x, hero.y, monDetritus.x, monDetritus.y) < hero.image:getWidth() / 1.5 and
                    monDetritus.image:getWidth() / 2
             then
                monDetritus.supprime = true
                sndMusicTouche:play()
            end
            ---------------------------------------------------------------------------hero 2
            if
                math.dist(hero2.x, hero2.y, monDetritus.x, monDetritus.y) < hero2.image:getWidth() / 1.5 and
                    monDetritus.image:getWidth() / 2
             then
                monDetritus.supprime = true
                sndMusicTouche:play()
            end

            if monDetritus.y < hauteur + monDetritus.h / 2 then
                monDetritus.y = monDetritus.y + 2 * (60 * dt)
            else
                monDetritus.supprime = true
                score = score - monDetritus.valeur
                monDetritus.valeur = 0
            end
        end

        for f = 1, #liste_pPoisson do
            local pPoisson = liste_pPoisson[f]
            if pPoisson.scaleX > 0 then
                if pPoisson.x < largeur then
                    pPoisson.x = pPoisson.x + 1.5
                end
            else
                pPoisson.x = pPoisson.x - pPoisson.speed
            end

            if pPoisson.x >= largeur then
                pPoisson.supprime = true
            end
            if pPoisson.drift == true and (largeur / 2) - 10 < pPoisson.x and pPoisson.x < (largeur / 2) + 10 then
                pPoisson.scaleX = -pPoisson.scaleX
                pPoisson.rota = -pPoisson.rota
            end
        end

        --purge des ennemies
        for n = #liste_ennemie, 1, -1 do
            if liste_ennemie[n].supprime == true then
                table.remove(liste_ennemie, n)
            end
        end

        if gameOver == true then
            for c = #liste_detritus, 1, -1 do
                liste_detritus[c].supprime = true
                liste_detritus[c].valeur = 0
                sndMusicTouche:stop()
            end
            for c = #liste_ennemie, 1, -1 do
                liste_ennemie[c].supprime = true
            end
            for c = #liste_sprite, 1, -1 do
                liste_sprite[c].supprime = true
            end
            ecran_courant = "gameover"
        end
        --purge des détritus
        for n = #liste_detritus, 1, -1 do
            if liste_detritus[n].supprime == true then
                table.remove(liste_detritus, n)
            end
        end
        --purge des pPoisson
        for f = #liste_pPoisson, 1, -1 do
            if liste_pPoisson[f].supprime == true then
                table.remove(liste_pPoisson, f)
            end
        end
        -- purge des sprites
        --quand on veut supprimer qqch d'une liste toujours vérifier du bas vers le haut
        -- variable = "#" (prendre le dernier) , "1" (aller vers le premier) , "-1" (pas de -1, manière d'avancer dans la liste)
        for n = #liste_sprite, 1, -1 do
            if liste_sprite[n].supprime == true then
                score = score + liste_sprite[n].valeur
                table.remove(liste_sprite, n)
            end
        end
        if #liste_ennemie < 1 then
            InitEnnemie(1, 3)
        end
        if #liste_detritus < 1 then
            InitDetritus()
        end
        if #liste_pPoisson < 1 then
            InitPPoisson()
        end
    end
    if ecran_courant == "gameover" then
        UpdateGameover()
        gameOver = false
    end
    if ecran_courant == "menu" then
        fond = imgMenu
        score = 300
    end
end

function love.draw()
    if ecran_courant == "jeu" then
        --fonction(variable image, pos X, pos Y, rota, agrandis. X, agrandis. Y, point d'origine X, point d'origine Y)
        love.graphics.draw(fond, 0, 0, 0, 2.6, 1.45, 0, 0)
        --affichage du score
        love.graphics.print(tostring(score), (largeur / 2) - 25, 0, 0, 4, 4)
        love.graphics.print("Vies P1: " .. tostring(hero.vie), 25, 0, 0, 2, 2)
        love.graphics.print("Dash : " .. tostring(math.floor(cdp1)), 25, 25, 0, 2, 2)
        love.graphics.print("Vies P2: " .. tostring(hero2.vie), 1400, 0, 0, 2, 2)
        love.graphics.print("Dash : " .. tostring(math.floor(cdp2)), 1400, 25, 0, 2, 2)
        -- love.graphics.print("Timer : " .. tostring(math.floor(timer)), 350, 0, 0, 2, 2)

        for c = 1, #liste_sprite do
            local s = liste_sprite[c]
            love.graphics.draw(s.image, s.x, s.y, s.rota, s.scaleX, s.scaleY, s.l / 2, s.h / 2)
        end
    end
    if ecran_courant == "gameover" then
        --fonction(variable image, pos X, pos Y, rota, agrandis. X, agrandis. Y, point d'origine X, point d'origine Y)
        love.graphics.draw(fond, 0, 0, 0, 3.5, 1.5, 0, 0)
        love.graphics.print("Score: " .. tostring(score), 650, 550, 0, 3, 3)
    end
    if ecran_courant == "menu" then
        --fonction(variable image, pos X, pos Y, rota, agrandis. X, agrandis. Y, point d'origine X, point d'origine Y)
        love.graphics.draw(fond, 0, 0, 0, 3.5, 1.5, 0, 0)
    end
end

function love.keypressed(key)
    -- si la touche escape est pressé, quitter le jeu
    if key == "escape" then
        love.event.quit()
    end

    if ecran_courant == "menu" then
        if key == "return" then
            ecran_courant = "jeu"
        end
    end

    if ecran_courant == "gameover" then
        if key == "space" or key == "return" then
            ecran_courant = "jeu"
            DemarreJeu()
        end
    end
end
