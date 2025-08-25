import { Search, Bell } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';

export function Header() {
  const navItems = [
    { label: 'Tudo', active: true },
    { label: 'Streaming', active: false },
    { label: 'Lançamentos', active: false },
    { label: 'Calendário', active: false },
    { label: 'Gêneros', active: false },
    { label: 'Temporadas', active: false },
  ];

  return (
    <header className="bg-gray-900 border-b border-gray-800">
      <div className="max-w-7xl mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center space-x-8">
            <div className="flex items-center space-x-2">
              <div className="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center">
                <div className="w-3 h-3 bg-white rounded-full"></div>
              </div>
              <h1 className="text-white text-xl font-semibold">AnimesKai</h1>
            </div>
          </div>
          
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <Input 
                type="search" 
                placeholder="Pesquisar..." 
                className="pl-10 w-64 bg-gray-800 border-gray-700 text-white placeholder-gray-400"
              />
            </div>
            <Button variant="ghost" size="icon" className="text-white hover:bg-gray-800">
              <Bell className="w-5 h-5" />
            </Button>
            <div className="w-8 h-8 bg-red-500 rounded-full flex items-center justify-center">
              <span className="text-white text-sm font-medium">A</span>
            </div>
          </div>
        </div>

        <nav className="flex space-x-6 pb-4">
          {navItems.map((item) => (
            <button
              key={item.label}
              className={`px-4 py-2 rounded-full text-sm ${
                item.active
                  ? 'bg-blue-500 text-white'
                  : 'text-gray-400 hover:text-white hover:bg-gray-800'
              }`}
            >
              {item.label}
            </button>
          ))}
        </nav>
      </div>
    </header>
  );
}