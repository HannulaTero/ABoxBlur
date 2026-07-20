/// @desc SELECT EXAMPLE.

if (keyboard_check_pressed(vk_anykey) == false)
{
  exit;
}


switch(keyboard_key)
{
  case ord("1"): {
    instance_destroy(PAR_ABoxBlur_Example);
    instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example1_Basic);
    break;
  }
  case ord("2"): {
    instance_destroy(PAR_ABoxBlur_Example);
    instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example2_Shapes);
    break;
  }
  case ord("3"): {
    instance_destroy(PAR_ABoxBlur_Example);
    instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example3_Draw);
    break;
  }
  case ord("4"): {
    instance_destroy(PAR_ABoxBlur_Example);
    instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example4_DoF);
    break;
  }
}