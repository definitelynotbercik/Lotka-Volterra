function tworzenie_planszy(wielkosc_planszy)
    ["n" for a in 1:wielkosc_planszy^2]
end

function losowanie(wielkosc_planszy)
    global plansza = tworzenie_planszy(wielkosc_planszy)
    mozliwosci = []
    szansa = []
    for b in 1:wielkosc_planszy^2
        push!(mozliwosci, b)
        push!(mozliwosci, b)
        push!(szansa, b)
    end
    for dove in 1:populacja_dove
        if mozliwosci != []
            dove1 = rand(mozliwosci,1)
            for (indeks, wartosc) in enumerate(mozliwosci)
                if wartosc == dove1[1]
                    deleteat!(mozliwosci, indeks)
                    break
                end
            end
            if plansza[dove1[1]] == "n"
                plansza[dove1[1]] = "D"
            else
                plansza[dove1[1]] *= "D"
            end
        else
            global populacja_dove -= 1
        end
    end
    for hawk in 1:populacja_hawk
        if mozliwosci != []
            hawk1 = rand(mozliwosci,1)
            for (indeks, wartosc) in enumerate(mozliwosci)
                if wartosc == hawk1[1]
                    deleteat!(mozliwosci, indeks)
                    break
                end
            end
            if plansza[hawk1[1]] == "n"
                plansza[hawk1[1]] = "H"
            else
                plansza[hawk1[1]] *= "H"
            end
        else
            global populacja_hawk -= 1
        end
    end
end

function procesy(plansza, alt=false)
    for i in plansza
        if i == "n"
            continue
        #dove
        elseif i == "D"
            global populacja_dove += 1
        elseif i == "DD"
            continue
        #hawk
        elseif i == "H"
            global populacja_hawk += 1
        elseif i == "HH"
            global populacja_hawk -= 2
        elseif i == "DH"
            p = rand(1:2)
            if p == 1
                global populacja_dove -= 1
                global populacja_hawk += 1
            else
                continue
            end
        end
    end
end

function Zmiany_przez_dni(wielkosc_planszy, liczba_dni)
    populacje_dove = []
    populacje_hawk = []
    for f in 1:liczba_dni
        push!(populacje_dove, populacja_dove)
        push!(populacje_hawk, populacja_hawk)
        losowanie(wielkosc_planszy)
        procesy(plansza)
    end
    return populacje_dove, populacje_hawk
end

using Plots
@userplot StackedArea
 
@recipe function f(pc::StackedArea)
    wielkosc_planszy, y = pc.args
    n = length(wielkosc_planszy)
    y = cumsum(y, dims=2)
    seriestype := :shape
 
    for c=1:size(y,2)
        sx = vcat(wielkosc_planszy, reverse(wielkosc_planszy))
        sy = vcat(y[:,c], c==1 ? zeros(n) : reverse(y[:,c-1]))
        @series (sx, sy)
    end
end

function StackedArea(populacje_dove, populacje_hawk)
    dni = []
    nazwy = ["dove", "hawk"]
    append!(dni, i for i in 1:liczba_dni)
    plotly(
        ylimits=(0, 2*wielkosc_planszy^2),
    )
    stackedarea(dni, [populacje_dove populacje_hawk], color = [:greens :orange], labels = reshape(nazwy,(1,2)), legend= :outertopleft)
end

populacja_dove = 50
populacja_hawk = 40
liczba_dni = 100
wielkosc_planszy = 12
zmiany = Zmiany_przez_dni(wielkosc_planszy,liczba_dni)
StackedArea(zmiany[1], zmiany[2])