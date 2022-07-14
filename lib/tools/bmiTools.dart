import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';

import '/system/extensions.dart';

class BmiTools {
  BmiTools._();

  static double calculateBmi(double height, double weight){
    final h = height / 100;
    final bmiResultNum = (weight / (h * h)).toDouble();

    return MathHelper.fixPrecisionRound(bmiResultNum, 2);
  }

  static String bmiDescription(BuildContext context, double bmi){
    var res = 'non';

    if(bmi < 18.5){
      res = context.tC('yourBmiD1')!;
    }
    else if(bmi >= 18.5 && bmi <= 24.9){
      res = context.tC('yourBmiD2')!;
    }
    else if(bmi >= 25 && bmi <= 29.9){
      res = context.tC('yourBmiD3')!;
    }
    else if(bmi >= 30 && bmi <= 34.9){
      res = context.tC('yourBmiD4')!;
    }
    else if(bmi >= 35){
      res = context.tC('yourBmiD4')!;
    }

    return res;
  }

  static double calculateBmr(double height, double weight, int age, int gender){
    double bmrResultNum1;
    double bmrResultNum2;

    if(gender == 0){
      bmrResultNum1 = (((weight * 13.75) + (height * 5)) - (age * 6.75) + 66.47).toDouble();
      bmrResultNum2 = (((weight * 10) + (height * 6.25)) - (age * 5) + 5).toDouble();
    }
    else {
      bmrResultNum1 = (((weight * 9.56) + (height * 1.84)) - (age * 4.67) + 665.09).toDouble();
      bmrResultNum2 = (((weight * 10) + (height * 6.25)) - (age * 5) - 161).toDouble();
    }

    bmrResultNum1 = bmrResultNum1.roundToDouble();// MathHelper.fixPrecisionRound(bmrResultNum1, 2);
    bmrResultNum2 = bmrResultNum2.roundToDouble();

    return bmrResultNum1;
  }

  static double calculateBmrRegister(double height, double weight, int age, int gender, int activityRate){
    final bmr = calculateBmr(height, weight, age, gender);
    var multi = 0.0;
    var add = 0;

    switch(activityRate){
      case 0:
        multi = 1.2;
        add = gender ==0? 31:30;
        break;
      case 1:
        multi = 1.3;
        add = gender ==0? 38:35;
        break;
      case 2:
        multi = 1.5;
        add = gender ==0? 41:37;
        break;
      case 3:
        multi = 2;
        add = gender ==0? 50:44;
        break;
      case 4:
        multi = 2;
        add = gender ==0? 58:51;
        break;
    }

    return bmr * multi + add;
  }
}
