import 'package:flutter/material.dart';

enum ContractStatus { active, suspended, ended }

class ContractData {
  const ContractData({
    required this.familyName,
    required this.childName,
    required this.childAge,
    required this.startDate,
    required this.contractEndDate,
    required this.monthlyAmount,
    required this.baseSalary,
    required this.hoursPerWeek,
    required this.monthlyHours,
    required this.weeksPerYear,
    required this.vacationWeeks,
    required this.hourlyRateNet,
    required this.hourlyRateGross,
    required this.maintenanceRate,
    required this.mealRate,
    required this.weeklyRest,
    required this.mayFirst,
    required this.pajemploiPlus,
    required this.weeklySchedule,
    required this.avatarColor,
    required this.status,
    this.endDate,
  });

  final String familyName;
  final String childName;
  final String childAge;
  final String startDate;
  final String contractEndDate;
  final String monthlyAmount;
  final String baseSalary;
  final String hoursPerWeek;
  final String monthlyHours;
  final String weeksPerYear;
  final String vacationWeeks;
  final String hourlyRateNet;
  final String hourlyRateGross;
  final String maintenanceRate;
  final String mealRate;
  final String weeklyRest;
  final String mayFirst;
  final String pajemploiPlus;
  final List<(String day, String hours)> weeklySchedule;
  final Color avatarColor;
  final ContractStatus status;
  final String? endDate;
}
