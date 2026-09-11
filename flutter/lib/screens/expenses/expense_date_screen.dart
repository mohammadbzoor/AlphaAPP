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

class ExpenseDateScreen extends StatefulWidget {
  final DateTime? initialDate;
  final bool isRecurring;

  const ExpenseDateScreen({
    super.key,
    this.initialDate,
    this.isRecurring = false,
  });

  @override
  State<ExpenseDateScreen> createState() =>
      _ExpenseDateScreenState();
}

class _ExpenseDateScreenState extends State<ExpenseDateScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late int _selectedYear;

  DateTime get _today {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  DateTime get _firstAllowedDay {
    return DateTime(
      DateTime.now().year - 20,
      1,
      1,
    );
  }

  DateTime get _lastAllowedDay {
    return widget.isRecurring
        ? DateTime(_today.year + 10, 12, 31)
        : _today;
  }

  @override
  void initState() {
    super.initState();

    final initialDate = widget.initialDate ?? _today;

    final normalizedInitialDate = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );

    if (normalizedInitialDate.isBefore(_firstAllowedDay)) {
      _selectedDay = _firstAllowedDay;
    } else if (normalizedInitialDate.isAfter(_lastAllowedDay)) {
      _selectedDay = _lastAllowedDay;
    } else {
      _selectedDay = normalizedInitialDate;
    }

    _focusedDay = _selectedDay;
    _selectedYear = _selectedDay.year;
  }

  DateTime _safeDate({
    required int year,
    required int month,
    required int day,
  }) {
    final lastDayOfMonth = DateTime(
      year,
      month + 1,
      0,
    ).day;

    final safeDay = day.clamp(
      1,
      lastDayOfMonth,
    );

    DateTime date = DateTime(
      year,
      month,
      safeDay,
    );

    if (date.isBefore(_firstAllowedDay)) {
      date = _firstAllowedDay;
    }

    if (date.isAfter(_lastAllowedDay)) {
      date = _lastAllowedDay;
    }

    return date;
  }

  void _selectYear(int year) {
    final nextDate = _safeDate(
      year: year,
      month: _selectedDay.month,
      day: _selectedDay.day,
    );

    setState(() {
      _selectedYear = nextDate.year;
      _selectedDay = nextDate;
      _focusedDay = nextDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);

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

    final locale = context.locale.toString();

    final firstYear = _firstAllowedDay.year;
    final lastYear = _lastAllowedDay.year;
    final yearCount = lastYear - firstYear + 1;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                      widget.isRecurring
                          ? 'expense_date.recurring_description'.tr()
                          : 'expense_date.description'.tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.026,
                    ),

                    Text(
                      'expense_date.year'.tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 45,
                      child: ListView.separated(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        physics:
                            const BouncingScrollPhysics(),
                        itemCount: yearCount,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 9),
                        itemBuilder: (context, index) {
                          final year = lastYear - index;
                          final isSelected =
                              year == _selectedYear;

                          return InkWell(
                            onTap: () {
                              _selectYear(year);
                            },
                            borderRadius:
                                BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : borderColor.withOpacity(
                                        isDark ? 0.45 : 0.55,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : borderColor,
                                ),
                              ),
                              child: Text(
                                '$year',
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color: isSelected
                                      ? Colors.white
                                      : subTextColor,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
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
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        8,
                        10,
                        14,
                      ),
                      decoration: BoxDecoration(
                        color:
                            primaryColor.withOpacity(0.04),
                        borderRadius:
                            BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              primaryColor.withOpacity(0.65),
                        ),
                      ),
                      child: TableCalendar(
                        locale: locale,
                        firstDay: _firstAllowedDay,
                        lastDay: _lastAllowedDay,
                        focusedDay: _focusedDay,
                        calendarFormat:
                            CalendarFormat.month,
                        availableCalendarFormats: {
                          CalendarFormat.month:
                              'expense_date.month'.tr(),
                        },
                        selectedDayPredicate: (day) {
                          return isSameDay(
                            _selectedDay,
                            day,
                          );
                        },
                        enabledDayPredicate: (day) {
                          final normalizedDay = DateTime(
                            day.year,
                            day.month,
                            day.day,
                          );

                          return !normalizedDay
                                  .isBefore(_firstAllowedDay) &&
                              !normalizedDay
                                  .isAfter(_lastAllowedDay);
                        },
                        onDaySelected: (
                          selectedDay,
                          focusedDay,
                        ) {
                          final normalizedDay = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );

                          if (normalizedDay
                                  .isBefore(_firstAllowedDay) ||
                              normalizedDay
                                  .isAfter(_lastAllowedDay)) {
                            return;
                          }

                          setState(() {
                            _selectedDay = normalizedDay;
                            _focusedDay = normalizedDay;
                            _selectedYear =
                                normalizedDay.year;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          final safeFocusedDay =
                              _safeDate(
                            year: focusedDay.year,
                            month: focusedDay.month,
                            day: focusedDay.day,
                          );

                          setState(() {
                            _focusedDay = safeFocusedDay;
                            _selectedYear =
                                safeFocusedDay.year;
                          });
                        },
                        daysOfWeekHeight: 28,
                        rowHeight: 46,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          headerPadding:
                              const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          titleTextStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left_rounded,
                            color: primaryColor,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right_rounded,
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
                              GoogleFonts.ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          weekendStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          isTodayHighlighted: true,
                          cellMargin:
                              const EdgeInsets.all(5),
                          defaultTextStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          disabledTextStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            color: subTextColor
                                .withOpacity(0.35),
                            fontSize: 12,
                          ),
                          todayTextStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          todayDecoration:
                              BoxDecoration(
                            color:
                                primaryColor.withOpacity(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor
                                  .withOpacity(0.45),
                            ),
                          ),
                          selectedTextStyle:
                              GoogleFonts.ibmPlexSansArabic(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                      selectedDay: _selectedDay,
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
                MediaQuery.paddingOf(context).bottom + 14,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: borderColor.withOpacity(0.7),
                  ),
                ),
              ),
              child: AppButton(
                text: 'expense_date.confirm_date'.tr(),
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

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            color: primaryColor,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'expense_date.title'.tr(),
            style: GoogleFonts.ibmPlexSansArabic(
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
                color: primaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.close_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedDateCard extends StatelessWidget {
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
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
                  'expense_date.selected_date'.tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
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
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
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
