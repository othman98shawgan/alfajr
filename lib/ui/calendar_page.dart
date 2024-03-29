import 'dart:convert';

import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/prayers.dart';
import '../services/day_of_year_service.dart';
import '../services/daylight_time_service.dart';
import '../services/locale_service.dart';
import '../services/prayer_methods.dart';
import '../services/theme_service.dart';
import 'widgets/prayer_widget.dart';
import 'dart:ui' as ui;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool summerTime = false;
  int dayInYear = 0;
  late PrayersModel prayersToday;
  var pickedDate = DateTime.now();

  String adjustTime(String time) {
    var currTimeDiff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
    if (!summerTime && currTimeDiff == 0) return time;
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    var today = DateTime.now();
    var dateTime = DateTime(today.year, today.month, today.day, hour, minute);
    dateTime = dateTime.add(Duration(hours: 1, minutes: currTimeDiff));
    time = "${dateTime.hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')}";
    return time;
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: DateTime(pickedDate.year - 50),
        lastDate: DateTime(pickedDate.year + 50),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDatePickerMode: DatePickerMode.day,
      );

  Future<void> readJson() async {
    dayInYear = dayOfYear(pickedDate);

    final String response = await rootBundle.loadString('lib/data/prayer-time.json');
    final data = await json.decode(response);

    setState(() {
      prayersToday = PrayersModel.fromJson(data["prayers"][dayInYear]);
    });
  }

  @override
  void initState() {
    super.initState();
    summerTime = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();
  }

  @override
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).viewPadding;
    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;
    double prayerCardHeight = height3 * 0.11;
    double mainCardHeight = height3 * 0.20;
    var sunIcon = const Icon(Icons.light_mode);
    var moonIcon = const Icon(Icons.dark_mode);
    var themeMode = Provider.of<ThemeNotifier>(context, listen: false).themeMode;
    var locale = Provider.of<LocaleNotifier>(context, listen: false).locale.toString();

    var dateTextWidget = Text(
      DateFormat('dd MMM yyyy', locale).format(pickedDate),
      style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 40,
          color: themeMode == ThemeMode.dark ? colorTextDark : colorTextLight),
    );

    var dateTextButtonWidget = Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: TextButton(
          onPressed: () async {
            final date = await pickDate();
            if (date != null && date != pickedDate) {
              setState(() {
                pickedDate = date;
              });
            }
          },
          child: dateTextWidget,
        ));

    HijriCalendar.setLocal(locale);

    return Consumer3<DaylightSavingNotifier, ThemeNotifier, LocaleNotifier>(
      builder: (context, daylightSaving, theme, localeProvider, child) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                AppLocalizations.of(context)!.calendarString,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  sharePrayerTimes(context, localeProvider, prayersToday, pickedDate);
                },
                tooltip: AppLocalizations.of(context)!.todayTooltip,
              ),
              IconButton(
                icon: summerTime ? sunIcon : moonIcon,
                onPressed: () {
                  setState(() {
                    summerTime = !summerTime;
                  });
                },
                tooltip: AppLocalizations.of(context)!.dstTooltip,
              ),
            ],
          ),
          body: FutureBuilder<List>(
            future: Future.wait([
              readJson(),
            ]),
            builder: (buildContext, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(theme.backgroundImage!), fit: BoxFit.cover)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      MyCard(
                          height: mainCardHeight,
                          widget: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('EEEE', localeProvider.locale.toString())
                                      .format(pickedDate)),
                                  const Text('  -  '),
                                  Text((HijriCalendar.fromDate(pickedDate)
                                      .toFormat('dd MMMM yyyy'))),
                                ],
                              ),
                              Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 36,
                                      icon: const Icon(Icons.navigate_before),
                                      onPressed: () {
                                        setState(() {
                                          pickedDate = pickedDate.subtract(const Duration(days: 1));
                                        });
                                      },
                                      tooltip: AppLocalizations.of(context)!.prevoiusDayTooltip,
                                    ),
                                    dateTextButtonWidget,
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 36,
                                      icon: const Icon(Icons.navigate_next),
                                      onPressed: () {
                                        setState(() {
                                          pickedDate = pickedDate.add(const Duration(days: 1));
                                        });
                                      },
                                      tooltip: AppLocalizations.of(context)!.nextDayTooltip,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                      PrayerWidget(
                        label: "Fajr",
                        time: adjustTime(prayersToday.fajr),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Shuruq",
                        time: adjustTime(prayersToday.shuruq),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Duhr",
                        time: adjustTime(prayersToday.duhr),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Asr",
                        time: adjustTime(prayersToday.asr),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Maghrib",
                        time: adjustTime(prayersToday.maghrib),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Isha",
                        time: adjustTime(prayersToday.isha),
                        height: prayerCardHeight,
                      ),
                    ],
                  ),
                );
              } else {
                // Return loading screen while reading preferences
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
