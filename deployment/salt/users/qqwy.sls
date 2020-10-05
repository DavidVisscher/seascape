qqwy:
  user.present:
    - fullname: Wiebe-Marten Wijnja
    - shell: /bin/bash
    - home: /home/qqwy
    - createhome: True
    - groups:
      - wheel

qqwy_key:
  ssh_auth.present:
    - name: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC17d5xA/S3o70jtnqTt4IbN1lOmrCWDwJ6O2lHPsm6g8oXoc934u2ZvH44xjNKOfjFi35ILuB67kMY+c25tgY8YSaFCYooa9eTr61NchnQcSTUC4gYA0EGkS0GpFfpKJHqDDSnE0+bzwCxQIXQgqI+GWfliNpeXw4VTvbUrZ/2FJfXm3Mi/GHt9tsKnJF8pkoRshCoBZ4DAPDwLJPB2vTN2036QwOXNJBUHhi4nGDfrz/DnqaW2V0WqO87k/tkYdQfak99jjwNObXUGfcMJ1g54uiJ7aWVeenXs8f+1Rxmlt0fIYKjYBvV655OwitX2OPzQkOG9Ns8XQCVq27XtdSl qqwy@Quinn"
    - user: qqwy
    - enc: ssh-rsa
    - require:
      - user: qqwy
