# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sportyweb.Repo.insert!(%Sportyweb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Sportyweb.Repo

alias Sportyweb.Accounts
alias Sportyweb.Organization.Club
alias Sportyweb.Organization.Department

###################################
# Add Users
# Only in the dev environment!

if Mix.env() in [:dev] do
  Accounts.register_user(%{
    email: "stefan.strecker@fernuni-hagen.de",
    password: "NTU5MTM5NGNmZjY",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "marvin.biesenbach@studium.fernuni-hagen.de",
    password: "MzU2OWY3NTQyNzI",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "sven.christ@fernuni-hagen.de",
    password: "ZThjNWY2NTQ3OGQ",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "bastian.kres@krewast.de",
    password: "MzU0MmJiZWI4ZmN",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "andrew.utley@studium.fernuni-hagen.de",
    password: "MGI3MTNlMzczZjR",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "tester@tester.de",
    password: "testertester"
  })
end

###################################
# Add Club 1

club_1 = Repo.insert!(%Club{
  name: "FC Bayern München",
  reference_number: "0815",
  website_url: "https://fcbayern.com/",
  founded_at: ~D[1900-02-27]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Herren",
  type: "Hauptabteilung",
  created_at: ~D[1900-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Damen",
  type: "Hauptabteilung",
  created_at: ~D[1905-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Basketball",
  type: "Hauptabteilung",
  created_at: ~D[1910-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Handball",
  type: "Hauptabteilung",
  created_at: ~D[1915-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Schach",
  type: "Hauptabteilung",
  created_at: ~D[1920-03-01]
})

###################################
# Add Club 2

club_2 = Repo.insert!(%Club{
  name: "1. FC Köln",
  reference_number: "xyz",
  website_url: "https://fc.de/",
  founded_at: ~D[1948-02-13]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Herren",
  type: "Hauptabteilung",
  created_at: ~D[1948-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Damen",
  type: "Hauptabteilung",
  created_at: ~D[1950-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Handball",
  type: "Hauptabteilung",
  created_at: ~D[1955-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Tischtennis",
  type: "Hauptabteilung",
  created_at: ~D[1960-03-01]
})

###################################
# Add Club 3

Repo.insert!(%Club{
  name: "FC St. Pauli",
  reference_number: "",
  website_url: "https://www.fcstpauli.com/",
  founded_at: ~D[1910-05-15]
})

###################################
# Add Club 4

Repo.insert!(%Club{
  name: "Keine-Website-Verein",
  reference_number: "",
  website_url: "",
  founded_at: ~D[2020-04-01]
})
