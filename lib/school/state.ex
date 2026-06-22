defmodule School.State do
  use GenServer

  alias School.Player
  alias School.Logic

  @max_active_rules 5
  @available_rules [
    :rule1,
    :rule2,
    :rule3,
    :rule4,
    :rule5,
    :rule6,
    :rule7,
    :rule8,
    :rule9,
    :rule10
  ]

  defstruct active_rules: [],
            players: []

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def add_player(pid) do
    GenServer.call(__MODULE__, {:add_player, pid})
  end

  def set_random_rule do
    GenServer.cast(__MODULE__, :set_random_rule)
  end

  def get_active_rules do
    GenServer.call(__MODULE__, :get_active_rules)
  end

  def update_player_score(pid, package, expected) do
    GenServer.call(__MODULE__, {:update_player_score, pid, package, expected})
  end

  @impl true
  def handle_cast(:set_random_rule, state) do
    new_state = maybe_activate_random_rule(state)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_active_rules, _from, state) do
    {:reply, state.active_rules, state}
  end

  @impl true
  def handle_call({:update_player_score, pid, package, expected}, _from, state) do
    {[player], remaining_players} =
      Enum.split_with(state.players, fn player -> player.pid == pid end)

    {validation_result, validation_msg} =
      Logic.validate(package, state.active_rules)

    decision =
      if validation_result == expected,
        do: :correct,
        else: :incorrect

    score_delta =
      if decision == :correct,
        do: 1,
        else: -1

    new_score = max(player.score + score_delta, 0)

    updated_player = Map.put(player, :score, new_score)

    updated_player_list = [updated_player | remaining_players]

    Phoenix.PubSub.broadcast(
      School.PubSub,
      "game_room",
      {:update_player_list, sort_by_score(updated_player_list)}
    )

    new_state = Map.put(state, :players, updated_player_list)

    {:reply, {updated_player, decision, validation_msg}, new_state}
  end

  @impl true
  def handle_call({:add_player, pid}, _from, state) do
    Process.monitor(pid)

    new_player = %Player{
      pid: pid,
      name: inspect(pid)
    }

    updated_player_list = [new_player | state.players]
    new_state = Map.put(state, :players, updated_player_list)

    Phoenix.PubSub.broadcast(
      School.PubSub,
      "game_room",
      {:update_player_list, updated_player_list}
    )

    {:reply, new_player, new_state}
  end

  # handle killed PID
  # {:DOWN, #Reference<0.4092222473.1123811329.133049>, :process, #PID<0.664.0>, {:shutdown, :closed}}
  @impl true
  def handle_info({:DOWN, _, _, pid, _}, state) do
    player_list = state.players
    updated_player_list = Enum.reject(player_list, fn player -> player.pid == pid end)
    new_state = Map.put(state, :players, updated_player_list)

    Phoenix.PubSub.broadcast(
      School.PubSub,
      "game_room",
      {:update_player_list, updated_player_list}
    )

    {:noreply, new_state}
  end

  defp maybe_activate_random_rule(state) do
    if length(state.active_rules) < @max_active_rules do
      activate_new_rule(state)
    else
      state
    end
  end

  defp activate_new_rule(state) do
    active_rules = state.active_rules

    new_rule =
      @available_rules
      |> Enum.reject(fn rule -> rule in active_rules end)
      |> Enum.random()

    new_state =
      Map.put(state, :active_rules, [new_rule | active_rules])

    new_state
  end

  defp sort_by_score(player_list) do
    Enum.sort(player_list, fn p1, p2 -> p1.score > p2.score end)
  end
end
