import { Compass, BookOpen, BarChart3, Users, MoreHorizontal } from 'lucide-react';

export function BottomNavigation() {
  const navItems = [
    { icon: Compass, label: 'Explorar', active: true },
    { icon: BookOpen, label: 'Biblioteca', active: false },
    { icon: BarChart3, label: 'Ranking', active: false },
    { icon: Users, label: 'Social', active: false },
    { icon: MoreHorizontal, label: 'Mais', active: false },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-gray-900 border-t border-gray-800">
      <div className="flex items-center justify-around py-2">
        {navItems.map((item) => {
          const IconComponent = item.icon;
          return (
            <button
              key={item.label}
              className={`flex flex-col items-center space-y-1 p-2 rounded-lg ${
                item.active ? 'text-blue-500' : 'text-gray-400 hover:text-white'
              }`}
            >
              <IconComponent className="w-5 h-5" />
              <span className="text-xs">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}