#include <amxmodx>
#include <CromChat>
#include <amxx4u>

#define get_points_rank(%1)		get_rank_points(%1)
#define set_points_rank(%1,%2)	set_rank_points(%1, %2)

enum _:CVARS
{
	MVP_KILL,
	MVP_KILL_HS,
	MVP_PLANTED,
	MVP_EXPLODE,
	MVP_DEFUSED,
	MVP_CT_WIN,
	MVP_TT_WIN,
	MVP_REWARD
};

static const NAME[]	  		= "MVP";
static const AUTHOR[] 		= "dredek";
static const URL_AUTHOR[]  	= "https://amxx4u.pl/"
static const VERSION[]	  	= "1.0";

static const chat_prefix[] 	= "&x07[» AMXX4u.pl «]&x01";

new mvp_points[MAX_PLAYERS + 1];
new mvp_cvars[CVARS];

public plugin_init()
{
	register_plugin(NAME, VERSION, AUTHOR, URL_AUTHOR);

	_register_event();
	_register_cvars();

	CC_SetPrefix(chat_prefix);
}

public client_putinserver(id)
	mvp_points[id] = 0;

public DeathMsg() 
{
	new killer = read_data(1);
	new victim = read_data(2);

	if(!is_user_connected(killer) || get_user_team(victim) == get_user_team(killer)) 
		return;

	mvp_points[killer] += read_data(3) ? mvp_cvars[MVP_KILL_HS] : mvp_cvars[MVP_KILL];
}

public bomb_planted(id) 
	mvp_points[id] += mvp_cvars[MVP_PLANTED];

public bomb_explode(id) 
	mvp_points[id] += mvp_cvars[MVP_EXPLODE];

public bomb_defused(id) 
	mvp_points[id] += mvp_cvars[MVP_DEFUSED];

public WinCT() 
{ 
	ForPlayers(i)
	{
		if(get_user_team(i) == 2)
			mvp_points[i] += mvp_cvars[MVP_CT_WIN];
	}
}

public WinTT() 
{
	ForPlayers(i)
	{
		if(get_user_team(i) == 1)
			mvp_points[i] += mvp_cvars[MVP_TT_WIN];
	}
}

public round_end() 
{
	new best_player;

	ForPlayers(i)
	{
		if(mvp_points[i] >= mvp_points[best_player])
			best_player = i;
	}

	new player_name[MAX_PLAYERS + 1];
	get_user_name(best_player, player_name, charsmax(player_name));

	set_points_rank(best_player, get_points_rank(best_player) + mvp_cvars[MVP_REWARD])

	CC_SendMessage(0, "Najbardziej wartosciowym zawodnikiem rundy zostal(a)&x04 %s&x01 (%d pkt.)", player_name, mvp_points[best_player]);
	CC_SendMessage(0, "W nagrode dostaje on(a)&x04 %d&x01 punkt(ow) do rangi!", mvp_cvars[MVP_REWARD]);
}

public new_round()
{
	ForPlayers(i)
		mvp_points[i] = 0;
}

_register_event()
{
	register_event("DeathMsg", "DeathMsg", "a");	
	register_event("SendAudio", "WinTT" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "WinCT", "a", "2&%!MRAD_ctwin");

	register_logevent("round_end", 2, "1=Round_End");
	register_logevent("new_round", 2, "1=Round_Start") 
}

_register_cvars()
{
	bind_pcvar_num(create_cvar("mvp_kill_points", "1",
		.description = "Ile punktow za zabójstwo gracza"), mvp_cvars[MVP_KILL]);

	bind_pcvar_num(create_cvar("mvp_killhs_points", "2",
		.description = "Ile punktow za zabójstwo gracza w glowe"), mvp_cvars[MVP_KILL_HS]);
	
	bind_pcvar_num(create_cvar("mvp_planted_points", "2",
		.description = "Ile punktow za podlozenie bomby"), mvp_cvars[MVP_PLANTED]);

	bind_pcvar_num(create_cvar("mvp_explode_points", "3",
		.description = "Ile punktow za wybuch bomby dla plantujacego"), mvp_cvars[MVP_EXPLODE]);

	bind_pcvar_num(create_cvar("mvp_defused_points", "2",
		.description = "Ile punktow za rozbrojenie bomby"), mvp_cvars[MVP_DEFUSED]);

	bind_pcvar_num(create_cvar("mvp_ctwin_points", "1",
		.description = "Ile punktow za wygranie rundy przez CT"), mvp_cvars[MVP_CT_WIN]);

	bind_pcvar_num(create_cvar("mvp_ttwin_points", "1",
		.description = "Ile punktow za wygranie rundy przez TT"), mvp_cvars[MVP_TT_WIN]);

	bind_pcvar_num(create_cvar("mvp_reward_points", "1",
		.description = "Ile punktow doliczyc do rangi za najwiecej pkt MVP"), mvp_cvars[MVP_REWARD]);

	create_cvar("amxx4u_pl", VERSION, FCVAR_SERVER);
}