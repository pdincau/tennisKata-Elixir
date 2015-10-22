defmodule Game do
  def start do
    game([0, 0])
  end

  def game([player_one, player_two]) do
    receive do
      {:get_score, pid} -> send pid, {:score, [player_one, player_two]}
      :player_one -> game(next_score(:player_one, [player_one, player_two]))
      :player_two -> game(next_score(:player_two, [player_one, player_two]))
    end
  end

  defp next_score(player, [player_one_score, player_two_score]) do
    case player do
      :player_one ->  add_point([player_one_score, player_two_score])
      :player_two ->  Enum.reverse(add_point([player_two_score, player_one_score]))               
    end
  end

  defp add_point([winner_score, loser_score]) do
    case [winner_score, loser_score] do
        [40, 40]-> [:advantage, 40] 
        [40, _] -> [:win, :lose]
        [30, _] -> [40, loser_score]
          _     -> [winner_score + 15, loser_score]
    end
  end
end

defmodule TennisKataTest do
  use ExUnit.Case

  test "it returns zero all" do
  	game = spawn_link(Game, :start, [])
  	send game, {:get_score, self}
  	assert_receive {:score, [0, 0]}
  end

  test "player one scored one point" do
    game = spawn_link(Game, :start, [])
    send game, :player_one
    send game, {:get_score, self}
    assert_receive {:score, [15, 0]}
  end

  test "player two scored one point" do
    game = spawn_link(Game, :start, [])
    send game, :player_two
    send game, {:get_score, self}
    assert_receive {:score, [0, 15]}
  end

  test "players scored one point" do
    game = spawn_link(Game, :start, [])
    send game, :player_one
    send game, :player_two
    send game, {:get_score, self}
    assert_receive {:score, [15, 15]}
  end

  test "player one scored two point" do
    game = spawn_link(Game, :start, [])
    send game, :player_one
    send game, :player_one
    send game, {:get_score, self}
    assert_receive {:score, [30, 0]}
  end

  test "player two scored two point" do
    game = spawn_link(Game, :start, [])
    send game, :player_two
    send game, :player_two
    send game, {:get_score, self}
    assert_receive {:score, [0, 30]}
  end

  test "a player scored three point" do
    game = spawn_link(Game, :start, [])
    send game, :player_one
    send game, :player_one
    send game, :player_one
    send game, {:get_score, self}
    assert_receive {:score, [40, 0]}
  end

  test "a player win the match" do
    game = spawn_link(Game, :start, [])
    send game, :player_one
    send game, :player_one
    send game, :player_one
    send game, :player_one
    send game, {:get_score, self}
    assert_receive {:score, [:win, _]}
  end

  test "a player lose the match" do
    game = spawn_link(Game, :start, [])
    send game, :player_two
    send game, :player_two
    send game, :player_two
    send game, :player_two
    send game, {:get_score, self}
    assert_receive {:score, [:lose, :win]}
  end

  test "player one in advantage" do
    game = spawn_link(Game, :start, [])
    send game, :player_two
    send game, :player_one
    send game, :player_two
    send game, :player_one
    send game, :player_two
    send game, :player_one
    send game, :player_one
    send game, {:get_score, self}
    assert_receive {:score, [:advantage, 40]}
  end

  test "player two in advantage" do
    game = spawn_link(Game, :start, [])
    send game, :player_two
    send game, :player_one
    send game, :player_two
    send game, :player_one
    send game, :player_two
    send game, :player_one
    send game, :player_two
    send game, {:get_score, self}
    assert_receive {:score, [40, :advantage]}
  end

end
