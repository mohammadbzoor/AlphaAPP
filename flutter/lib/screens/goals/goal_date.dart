import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class GoalDateScreen extends StatefulWidget {
  final DateTime? initialDate;

  const GoalDateScreen({
    super.key,
    this.initialDate,
  });

  @override
  State<GoalDateScreen> createState() =>
      _GoalDateScreenState();
}

class _GoalDateScreenState extends State<GoalDateScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late int _selectedYear;

  DateTime get _tomorrow {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day + 1,
    );
  }

  DateTime get _lastAllowedDay {
    return DateTime(
      DateTime.now().year + 7,
      12,
      31,
    );
  }

  @override
  void initState() {
    super.initState();

    final initialDate = widget.initialDate ??
        DateTime.now().add(
          const Duration(days: 30),
        );

    _selectedDay = initialDate.isBefore(_tomorrow)
        ? _tomorrow
        : initialDate;

    _focusedDay = _selectedDay;
    _selectedYear = _selectedDay.year;
  }

  void _selectYear(int year) {
    final now = DateTime.now();

    DateTime nextDate;

    if (year == now.year) {
      nextDate = DateTime(
        year,
        _selectedDay.month,
        _selectedDay.day,
      );

      if (nextDate.isBefore(_tomorrow)) {
        nextDate = _tomorrow;
      }
    } else {
      nextDate = DateTime(
        year,
        _selectedDay.month,
        _selectedDay.day,
      );
    }

    if (nextDate.isAfter(_lastAllowedDay)) {
      nextDate = _lastAllowedDay;
    }

    setState(() {
      _selectedYear = year;
      _selectedDay = nextDate;
      _focusedDay = nextDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);
    final locale = context.locale.toString();

    final isDark =
        context.watch<Themeprovider>().isDark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.055,
                  18,
                  screenW * 0.055,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _Header(
                      isDark: isDark,
                      screenW: screenW,
                      onClose: () {
                        Navigator.pop(context);
                      },
                    ),

                    SizedBox(
                      height: screenH * 0.012,
                    ),

                    Text(
                      "goal_date.description".tr(),
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.026,
                    ),

                    Text(
                      "goal_date.year".tr(),
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: textColor,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        scrollDirection:
                            Axis.horizontal,
                        physics:
                            const BouncingScrollPhysics(),
                        itemCount: 21,
                        separatorBuilder: (_, __) =>
                            const SizedBox(
                          width: 9,
                        ),
                        itemBuilder:
                            (context, index) {
                          final year =
                              DateTime.now().year +
                                  index;

                          final isSelected =
                              year ==
                                  _selectedYear;

                          return InkWell(
                            onTap: () {
                              _selectYear(year);
                            },
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 180,
                              ),
                              alignment:
                                  Alignment.center,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 18,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : borderColor
                                        .withOpacity(
                                          isDark
                                              ? 0.45
                                              : 0.55,
                                        ),
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : borderColor,
                                ),
                              ),
                              child: Text(
                                "$year",
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color: isSelected
                                      ? Colors.white
                                      : subTextColor,
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight
                                              .bold
                                          : FontWeight
                                              .w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.022,
                    ),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        10,
                        8,
                        10,
                        14,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor
                            .withOpacity(0.04),
                        borderRadius:
                            BorderRadius.circular(24),
                        border: Border.all(
                          color: primaryColor,
                        ),
                      ),
                      child: TableCalendar(
                        locale: locale,
                        firstDay: _tomorrow,
                        lastDay: _lastAllowedDay,
                        focusedDay: _focusedDay,
                        calendarFormat:
                            CalendarFormat.month,
                        availableCalendarFormats: {
  CalendarFormat.month: "goal_date.month".tr(),
},
                        selectedDayPredicate:
                            (day) {
                          return isSameDay(
                            _selectedDay,
                            day,
                          );
                        },
                        enabledDayPredicate:
                            (day) {
                          return !day.isBefore(
                            _tomorrow,
                          );
                        },
                        onDaySelected: (
                          selectedDay,
                          focusedDay,
                        ) {
                          setState(() {
                            _selectedDay =
                                selectedDay;
                            _focusedDay =
                                focusedDay;
                            _selectedYear =
                                selectedDay.year;
                          });
                        },
                        onPageChanged:
                            (focusedDay) {
                          setState(() {
                            _focusedDay =
                                focusedDay;
                            _selectedYear =
                                focusedDay.year;
                          });
                        },
                        daysOfWeekHeight: 28,
                        rowHeight: 46,
                        headerStyle: HeaderStyle(
                          formatButtonVisible:
                              false,
                          titleCentered: true,
                          headerPadding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 10,
                          ),
                          titleTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: textColor,
                          ),
                          leftChevronIcon: Icon(
                            Icons
                                .chevron_left_rounded,
                            color: primaryColor,
                          ),
                          rightChevronIcon: Icon(
                            Icons
                                .chevron_right_rounded,
                            color: primaryColor,
                          ),
                          leftChevronMargin:
                              EdgeInsets.zero,
                          rightChevronMargin:
                              EdgeInsets.zero,
                        ),
                        daysOfWeekStyle:
                            DaysOfWeekStyle(
                          weekdayStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                          weekendStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        calendarStyle:
                            CalendarStyle(
                          outsideDaysVisible: false,
                          isTodayHighlighted: true,
                          cellMargin:
                              const EdgeInsets.all(
                            5,
                          ),
                          defaultTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: textColor,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                          weekendTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: textColor,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w500,
                          ),
                          disabledTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: subTextColor
                                .withOpacity(0.35),
                            fontSize: 12,
                          ),
                          todayTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: primaryColor,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          todayDecoration:
                              BoxDecoration(
                            color: primaryColor
                                .withOpacity(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor
                                  .withOpacity(
                                    0.45,
                                  ),
                            ),
                          ),
                          selectedTextStyle:
                              GoogleFonts
                                  .ibmPlexSansArabic(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          selectedDecoration:
                              BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.02,
                    ),

                    _SelectedDateCard(
                      selectedDay:
                          _selectedDay,
                      isDark: isDark,
                      screenW: screenW,
                      locale: locale,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(
                screenW * 0.055,
                12,
                screenW * 0.055,
                MediaQuery.paddingOf(context)
                        .bottom +
                    14,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: borderColor
                        .withOpacity(0.7),
                  ),
                ),
              ),
              child: AppButton(
                text: "goal_date.confirm_date".tr(),
                isDark: isDark,
                width: double.infinity,
                height: 54,
                onPressed: () {
                  Navigator.pop(
                    context,
                    _selectedDay,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final double screenW;
  final VoidCallback onClose;

  const _Header({
    required this.isDark,
    required this.screenW,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                primaryColor.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.event_available_outlined,
            color: primaryColor,
            size: 23,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            "goal_date.title".tr(),
            style:
                GoogleFonts.ibmPlexSansArabic(
              fontSize: screenW * 0.062,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),

       Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onClose,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkPrimary.withOpacity(0.10)
            : AppColors.lightPrimary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.close_rounded,
        color: isDark
            ? AppColors.darkPrimary
            : AppColors.lightPrimary,
        size: 22,
      ),
    ),
  ),
),
      ],
    );
  }
}

class _SelectedDateCard
    extends StatelessWidget {
  final DateTime selectedDay;
  final bool isDark;
  final double screenW;
  final String locale;

  const _SelectedDateCard({
    required this.selectedDay,
    required this.isDark,
    required this.screenW,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              primaryColor.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  primaryColor.withOpacity(0.14),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "goal_date.selected_date".tr(),
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat(
                    'EEEE, MMMM d, yyyy',
                    locale,
                  ).format(selectedDay),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    fontSize: screenW * 0.043,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}