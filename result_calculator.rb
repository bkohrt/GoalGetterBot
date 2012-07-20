#encoding:utf-8
require_relative "comunio_service"

class ResultCalculator
  def initialize
    @service = ComunioService.new
    clubs = @service.clubs
    @club_comunio_ids = createClubAssignment clubs
    @norm = calculateNorm clubs
  end
  
  def matchResult team1, team2
    team1 = verifyName team1
    team2 = verifyName team2
    team1_scores = teamScores team1
    team2_scores = teamScores team2
    power_diff = clubDistance(team1_scores,team2_scores)
    offence_value_team1 = offenceValue team2_scores[:defence], team1_scores[:offence]
    offence_value_team2 = offenceValue team1_scores[:defence], team2_scores[:offence]
    result = result power_diff, offence_value_team1, offence_value_team2
  end
  
  def createClubAssignment clubsInfo
    club_comunio_ids = Hash.new
    clubsInfo.each do |club|
      club_comunio_ids[club[:name]] = club[:id]
    end
    club_comunio_ids
  end
  
  def teamScores teamName
    comunioId = @club_comunio_ids[teamName]
    players = @service.playersOfClub comunioId
    scores = {:points => 0, :quote => 0, :defence => 0, :offence => 0}
    if players      
      players.each do |player|
        if player[:status] == "ACTIVE"
          scores[:points] += player[:points].to_i
          scores[:quote] += player[:quote].to_i
          scores[:defence] += player[:points].to_i if player[:position] == "defender" || player[:position] == "keeper"
          scores[:offence] += player[:points].to_i if player[:position] == "striker"
        end
      end
      scores
    else
      0.to_i
    end    
  end
  
  def calculateNorm clubs
    offence_points = 0
    defence_points = 0
    clubs.each do |club|
      @service.playersOfClub(club[:id]).each do |player|
        defence_points += player[:points].to_i if player[:position] == "defender" || player[:position] == "keeper"
        offence_points += player[:points].to_i if player[:position] == "striker"
      end
    end
    {:offence => offence_points/clubs.size, :defence => defence_points/clubs.size}
  end
  
  def clubDistance team1_scores, team2_scores
    point_diff = pointDiff team1_scores[:points].to_f, team2_scores[:points].to_f
    quote_diff = quoteDiff team1_scores[:quote].to_f, team2_scores[:quote].to_f
    ((3*point_diff+quote_diff)/4).round
  end
  
  def pointDiff pointsTeam1, pointsTeam2
    pointsTeam1 = 1 if pointsTeam1 < 1
    pointsTeam2 = 1 if pointsTeam2 < 1
    diff = 0
    if pointsTeam1 > pointsTeam2
      diff = (pointsTeam1/pointsTeam2).round
      diff = diff > 3 ? 3 : diff
    elsif pointsTeam2 > pointsTeam1
      diff = -((pointsTeam2/pointsTeam1).round)
      diff = diff < -3 ? -3 : diff
    end
    diff.to_f
  end  
  
  def quoteDiff quoteTeam1, quoteTeam2
    diff = 0
    if quoteTeam1 > quoteTeam2
      diff = (quoteTeam1/quoteTeam2).round
      diff = diff > 3 ? 3 : diff
    elsif quoteTeam2 > quoteTeam1
      diff = -((quoteTeam2/quoteTeam1).round)
      diff = diff < -3 ? -3 : diff
    end
    diff.to_f
  end
  
  def offenceValue defence, offence
    normValue = (@norm[:defence]-@norm[:offence])
    return 0.to_i if normValue < 5 #Ab wann ist sind ausreichend Punkte vergeben worden?!
    value = (defence-offence)
    value = 1 if value < 1
    offenceValue = (normValue/value).round.abs
    offenceValue > 2 ? 2 : offenceValue
  end
  
  def result power, offence_value_team1, offence_value_team2
    if power > 0
      [power + offence_value_team2, 0 + offence_value_team2]
    elsif power < 0
      [0 + offence_value_team1, (power*-1) + offence_value_team1]
    else
      offence_value_team1 > offence_value_team2 ? [offence_value_team1,offence_value_team1] : [offence_value_team2,offence_value_team2]
    end
  end
  
  def verifyName name
    return name if @club_comunio_ids.has_key?(name)
    @club_comunio_ids.keys.each do |club|
      return club if club.include?(name) || club.include?(name[-6..-1])
    end
    raise "#{name} konnte nicht gefunden werden."
  end
end