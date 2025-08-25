import { Header } from './components/Header';
import { AnimeCard } from './components/AnimeCard';
import { BottomNavigation } from './components/BottomNavigation';
import { Grid } from 'lucide-react';

const animeData = [
  {
    id: 1,
    title: "Silent Witch: Chinmoku no Maj...",
    rating: 78.0,
    image: "https://images.unsplash.com/photo-1747919778477-3f1155231900?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMGNoYXJhY3RlciUyMGFjdGlvbnxlbnwxfHx8fDE3NTU5OTM3MjZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 2,
    title: "Dandadan 2nd Season",
    rating: 83.0,
    image: "https://images.unsplash.com/photo-1663035045563-24d54c1e8e28?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMGZhbnRhc3klMjBtYWdpY3xlbnwxfHx8fDE3NTU5OTM3Mjd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 3,
    title: "Yofukashi no Uta Season 2",
    rating: 81.0,
    image: "https://images.unsplash.com/photo-1675078835355-c2a17a90720c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMHdhcnJpb3IlMjBzd29yZHxlbnwxfHx8fDE3NTU5OTM3Mjd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 4,
    title: "Mizu Zokusui no Mahou Tsukai",
    rating: 68.0,
    image: "https://images.unsplash.com/photo-1610114586897-20495783e96c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMG5hdHVyZSUyMHBlYWNlZnVsfGVufDF8fHx8MTc1NTk5MzcyOHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 5,
    title: "Tougen Anki",
    rating: 67.0,
    image: "https://images.unsplash.com/photo-1705478563275-a4693b6bf2cd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMHJvYm90JTIwbWVjaGF8ZW58MXx8fHwxNzU1OTkzNzI4fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 6,
    title: "Dr. STONE: SCIENCE FUTURE Part 2",
    rating: 86.0,
    image: "https://images.unsplash.com/photo-1632368337183-780e87def5b1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMGN1dGUlMjBjaGFyYWN0ZXJzfGVufDF8fHx8MTc1NTk5MzcyOHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 7,
    title: "Zutaboro Rajou wa Ane no Moto Kon...",
    rating: 69.0,
    image: "https://images.unsplash.com/photo-1675929112281-7fad4e8b0687?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMGRhcmslMjBnb3RoaWN8ZW58MXx8fHwxNzU1OTkzNzI5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 8,
    title: "ONE PIECE",
    rating: 85.0,
    image: "https://images.unsplash.com/photo-1648464677854-bb2103d140b9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMHBpcmF0ZSUyMGFkdmVudHVyZXxlbnwxfHx8fDE3NTU5OTM3Mjl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 9,
    title: "Watari-kun no xx ga Houkai Sunzen",
    rating: 59.0,
    image: "https://images.unsplash.com/photo-1735720518739-3f519a8b5a73?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMHNjaG9vbCUyMHVuaWZvcm18ZW58MXx8fHwxNzU1OTkzNzI5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    id: 10,
    title: "Haikyuu!! Sports Festival",
    rating: 92.0,
    image: "https://images.unsplash.com/photo-1620328038775-6e8c620277b6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbmltZSUyMHNwb3J0cyUyMGNvbXBldGl0aW9ufGVufDF8fHx8MTc1NTk5MzcyOXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  }
];

export default function App() {
  return (
    <div className="min-h-screen bg-gray-900 pb-20">
      <Header />
      
      <main className="max-w-7xl mx-auto px-4 py-6">
        {/* Animes Section */}
        <section className="mb-8">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-white text-xl font-medium">Animes</h2>
            <button className="text-gray-400 hover:text-white">
              <Grid className="w-5 h-5" />
            </button>
          </div>
          
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
            {animeData.map((anime) => (
              <AnimeCard
                key={anime.id}
                title={anime.title}
                rating={anime.rating}
                image={anime.image}
              />
            ))}
          </div>
        </section>

        {/* News Section */}
        <section>
          <h2 className="text-white text-xl font-medium mb-6">Notícias</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {[1, 2, 3].map((item) => (
              <div
                key={item}
                className="bg-gradient-to-br from-blue-400 to-blue-600 rounded-lg h-48 flex items-center justify-center"
              >
                <div className="text-center text-white">
                  <h3 className="text-lg font-medium mb-2">Notícia {item}</h3>
                  <p className="text-blue-100">Conteúdo em breve...</p>
                </div>
              </div>
            ))}
          </div>
        </section>
      </main>

      <BottomNavigation />
    </div>
  );
}