case $RELEASE_COMMAND in
  start*|daemon*)
    ELIXIR_ERL_OPTIONS="-kernel inet_dist_listen_min $BEAM_PORT inet_dist_listen_max $BEAM_PORT"
    export ELIXIR_ERL_OPTIONS
    ;;
  *)
    ;;
esac