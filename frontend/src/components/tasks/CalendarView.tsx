'use client';

import { Task } from '@/lib/types';
import { useState } from 'react';
import {
  getCalendarDays,
  getMonthName,
  getPreviousMonth,
  getNextMonth,
  getTasksForDate,
  formatDate,
} from '@/lib/calendarUtils';

export interface CalendarViewProps {
  tasks: Task[];
  onTaskClick?: (task: Task) => void;
  onDateClick?: (date: Date) => void;
}

/**
 * Enhanced calendar view component for visualizing tasks by due date
 */
export const CalendarView: React.FC<CalendarViewProps> = ({ tasks, onTaskClick, onDateClick }) => {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);

  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();
  const calendarDays = getCalendarDays(year, month);

  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const goToPreviousMonth = () => {
    const { year: newYear, month: newMonth } = getPreviousMonth(year, month);
    setCurrentDate(new Date(newYear, newMonth, 1));
  };

  const goToNextMonth = () => {
    const { year: newYear, month: newMonth } = getNextMonth(year, month);
    setCurrentDate(new Date(newYear, newMonth, 1));
  };

  const goToToday = () => {
    setCurrentDate(new Date());
    setSelectedDate(null);
  };

  const handleDateClick = (date: Date) => {
    setSelectedDate(date);
    onDateClick?.(date);
  };

  const isToday = (date: Date) => {
    const today = new Date();
    return (
      date.getDate() === today.getDate() &&
      date.getMonth() === today.getMonth() &&
      date.getFullYear() === today.getFullYear()
    );
  };

  const isSameDay = (date1: Date, date2: Date | null) => {
    if (!date2) return false;
    return (
      date1.getDate() === date2.getDate() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getFullYear() === date2.getFullYear()
    );
  };

  return (
    <div className="bg-white rounded-2xl border border-neutral-200 p-6 shadow-lg">
      {/* Calendar Header */}
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-xl font-bold text-neutral-900 flex items-center gap-2">
          📅 Calendar View
        </h3>
        <div className="flex items-center gap-2">
          <button
            onClick={goToPreviousMonth}
            className="p-2 hover:bg-neutral-100 rounded-lg transition-colors"
            title="Previous month"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button
            onClick={goToToday}
            className="px-3 py-1.5 text-sm bg-primary-100 text-primary-700 rounded-lg hover:bg-primary-200 transition-colors font-medium"
          >
            Today
          </button>
          <button
            onClick={goToNextMonth}
            className="p-2 hover:bg-neutral-100 rounded-lg transition-colors"
            title="Next month"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      </div>

      {/* Month and Year */}
      <div className="text-center mb-4">
        <h4 className="text-2xl font-bold text-neutral-900">
          {getMonthName(month)} {year}
        </h4>
      </div>

      {/* Day Names */}
      <div className="grid grid-cols-7 gap-2 mb-2">
        {dayNames.map(day => (
          <div key={day} className="text-center text-sm font-semibold text-neutral-600 py-2">
            {day}
          </div>
        ))}
      </div>

      {/* Calendar Grid */}
      <div className="grid grid-cols-7 gap-2">
        {calendarDays.map((dayInfo, index) => {
          if (!dayInfo.date) {
            return <div key={`empty-${index}`} className="aspect-square" />;
          }

          const date = dayInfo.date;
          const dayTasks = getTasksForDate(tasks, date);
          const today = new Date();
          const hasOverdue = dayTasks.some(t => !t.completed && t.due_date && new Date(t.due_date) < today);
          const completedCount = dayTasks.filter(t => t.completed).length;
          const pendingCount = dayTasks.filter(t => !t.completed).length;
          const isCurrentMonth = dayInfo.isCurrentMonth;
          const isTodayDate = isToday(date);
          const isSelected = isSameDay(date, selectedDate);

          return (
            <button
              key={index}
              onClick={() => handleDateClick(date)}
              className={`aspect-square border rounded-lg p-2 transition-all hover:shadow-md cursor-pointer ${
                isTodayDate
                  ? 'bg-primary-50 border-primary-300 ring-2 ring-primary-200'
                  : isSelected
                  ? 'bg-primary-100 border-primary-400'
                  : isCurrentMonth
                  ? 'border-neutral-200 hover:border-primary-200 hover:bg-neutral-50'
                  : 'border-neutral-100 bg-neutral-50 opacity-50'
              }`}
            >
              <div className="flex flex-col h-full">
                {/* Day number */}
                <div className={`text-sm font-semibold mb-1 ${
                  isTodayDate
                    ? 'text-primary-700'
                    : isCurrentMonth
                    ? 'text-neutral-700'
                    : 'text-neutral-400'
                }`}>
                  {date.getDate()}
                </div>

                {/* Task indicators */}
                {dayTasks.length > 0 && isCurrentMonth && (
                  <div className="flex-1 flex flex-col gap-1 overflow-hidden">
                    {dayTasks.slice(0, 2).map(task => (
                      <div
                        key={task.id}
                        onClick={(e) => {
                          e.stopPropagation();
                          onTaskClick?.(task);
                        }}
                        className={`text-xs px-1.5 py-0.5 rounded truncate text-left transition-colors ${
                          task.completed
                            ? 'bg-green-100 text-green-700 hover:bg-green-200'
                            : hasOverdue
                            ? 'bg-red-100 text-red-700 hover:bg-red-200'
                            : 'bg-blue-100 text-blue-700 hover:bg-blue-200'
                        }`}
                        title={task.title}
                      >
                        {task.completed ? '✓' : '○'} {task.title}
                      </div>
                    ))}
                    {dayTasks.length > 2 && (
                      <div className="text-xs text-neutral-500 px-1.5">
                        +{dayTasks.length - 2} more
                      </div>
                    )}
                  </div>
                )}

                {/* Task count summary */}
                {dayTasks.length > 0 && isCurrentMonth && (
                  <div className="text-xs text-neutral-500 mt-auto pt-1 flex items-center gap-1">
                    {pendingCount > 0 && <span className="text-blue-600">{pendingCount}</span>}
                    {completedCount > 0 && <span className="text-green-600">✓{completedCount}</span>}
                  </div>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {/* Legend */}
      <div className="mt-6 pt-4 border-t border-neutral-200 flex items-center justify-center gap-6 text-sm">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-blue-100 border border-blue-200 rounded"></div>
          <span className="text-neutral-600">Pending</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-green-100 border border-green-200 rounded"></div>
          <span className="text-neutral-600">Completed</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-red-100 border border-red-200 rounded"></div>
          <span className="text-neutral-600">Overdue</span>
        </div>
      </div>
    </div>
  );
};

export default CalendarView;
