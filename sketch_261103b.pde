
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

class Match {
  String date;
  String opponent;
  String result;
  int scored;
  int conceded;
  int dateKey;

  Match(String date, String opponent, String result,
        int scored, int conceded, int dateKey) {
    this.date = date;
    this.opponent = opponent;
    this.result = result;
    this.scored = scored;
    this.conceded = conceded;
    this.dateKey = dateKey;
  }
}

ArrayList<Match> matches = new ArrayList<Match>();

int wins = 0;
int draws = 0;
int losses = 0;

String message = "";

void setup() {
  size(1000, 700);
  smooth();

  String[] files = {
    "2324.csv",
    "2425.csv",
    "2526.csv",
    "2627.csv"
  };

  for (String filename : files) {
    Table data = null;

    try {
      data = loadTable(filename, "header,csv");
    }
    catch (Exception e) {
      println("Could not load " + filename);
    }

    // Prevent NullPointerException
    if (data == null) {
      println("Missing or invalid file: " + filename);
      continue;
    }

    println("Loaded: " + filename);

    for (TableRow row : data.rows()) {
      try {
        String home = row.getString("HomeTeam");
        String away = row.getString("AwayTeam");
        String date = row.getString("Date");
        String hg = row.getString("FTHG");
        String ag = row.getString("FTAG");

        if (home == null || away == null ||
            date == null || hg == null || ag == null) {
          continue;
        }

        home = trim(home);
        away = trim(away);

        if (!home.equalsIgnoreCase("Chelsea") &&
            !away.equalsIgnoreCase("Chelsea")) {
          continue;
        }

        if (trim(hg).length() == 0 ||
            trim(ag).length() == 0) {
          continue;
        }

        int homeGoals = Integer.parseInt(trim(hg));
        int awayGoals = Integer.parseInt(trim(ag));

        boolean chelseaHome =
          home.equalsIgnoreCase("Chelsea");

        int scored = chelseaHome ? homeGoals : awayGoals;
        int conceded = chelseaHome ? awayGoals : homeGoals;

        String opponent = chelseaHome ? away : home;

        String result = "D";

        if (scored > conceded) {
          result = "W";
        } else if (scored < conceded) {
          result = "L";
        }

        String[] parts = split(date, '/');

        if (parts.length != 3) {
          continue;
        }

        int day = Integer.parseInt(trim(parts[0]));
        int month = Integer.parseInt(trim(parts[1]));
        int year = Integer.parseInt(trim(parts[2]));

        if (year < 100) {
          year += 2000;
        }

        int dateKey = year * 10000 + month * 100 + day;

        matches.add(new Match(
          date, opponent, result,
          scored, conceded, dateKey
        ));

      }
      catch (Exception e) {
        // Skip incomplete or invalid rows
        println("Skipped invalid match row");
      }
    }
  }

  // Sort matches from oldest to newest
  Collections.sort(matches, new Comparator<Match>() {
    public int compare(Match a, Match b) {
      return Integer.compare(a.dateKey, b.dateKey);
    }
  });

  // Keep the latest 100 matches
  while (matches.size() > 100) {
    matches.remove(0);
  }

  // Calculate statistics
  for (Match m : matches) {
    if (m.result.equals("W")) {
      wins++;
    } else if (m.result.equals("D")) {
      draws++;
    } else {
      losses++;
    }
  }

  if (matches.size() == 0) {
    message = "No match data found. Check your CSV files.";
  } else if (matches.size() < 100) {
    message = "Only " + matches.size() +
              " Chelsea matches were found.";
  } else {
    message = "Displaying Chelsea's latest 100 league matches";
  }

  println(message);
}

void draw() {
  background(10, 28, 85);

  // Chelsea title
  textAlign(CENTER);
  fill(255);
  textSize(40);
  text("CHELSEA FC", width / 2, 65);

  textSize(20);
  text("LAST 100 PREMIER LEAGUE RESULTS",
       width / 2, 105);

  // Draw divider
  stroke(80, 130, 220);
  strokeWeight(2);
  line(80, 125, 920, 125);

  // Statistics
  textSize(24);

  fill(45, 220, 100);
  text("WINS: " + wins, 220, 170);

  fill(255, 215, 50);
  text("DRAWS: " + draws, 500, 170);

  fill(255, 75, 75);
  text("LOSSES: " + losses, 780, 170);

  // Draw the match circles
  for (int i = 0; i < matches.size(); i++) {
    Match m = matches.get(i);

    int column = i % 10;
    int row = i / 10;

    float x = 95 + column * 90;
    float y = 235 + row * 38;

    boolean hovered =
      dist(mouseX, mouseY, x, y) < 15;

    // Match result colours
    if (m.result.equals("W")) {
      fill(40, 220, 110);
    } else if (m.result.equals("D")) {
      fill(255, 210, 50);
    } else {
      fill(245, 65, 75);
    }

    noStroke();

    if (hovered) {
      circle(x, y, 32);
    } else {
      circle(x, y, 22);
    }

    // Display hovered match information
    if (hovered) {
      fill(255);
      textAlign(CENTER);
      textSize(20);

      text("Chelsea " + m.scored +
           " - " + m.conceded +
           " " + m.opponent,
           width / 2, 630);

      textSize(16);
      text("Match date: " + m.date,
           width / 2, 660);
    }
  }

  // Legend
  fill(40, 220, 110);
  circle(290, 565, 15);

  fill(255);
  textSize(15);
  text("Win", 325, 571);

  fill(255, 210, 50);
  circle(450, 565, 15);

  fill(255);
  text("Draw", 490, 571);

  fill(245, 65, 75);
  circle(620, 565, 15);

  fill(255);
  text("Loss", 660, 571);

  // Status information
  fill(190, 210, 255);
  textSize(14);
  text(message, width / 2, 605);

  // Bottom information
  fill(160, 180, 220);
  textSize(13);
  text("Data source: Football-Data.co.uk",
       width / 2, 690);
}
