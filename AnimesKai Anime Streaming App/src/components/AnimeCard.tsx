import { Star } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface AnimeCardProps {
  title: string;
  rating: number;
  image: string;
}

export function AnimeCard({ title, rating, image }: AnimeCardProps) {
  return (
    <div className="bg-gray-800 rounded-lg overflow-hidden hover:bg-gray-750 transition-colors cursor-pointer group">
      <div className="aspect-[3/4] relative overflow-hidden">
        <ImageWithFallback
          src={image}
          alt={title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        />
        <div className="absolute top-2 right-2 bg-black/70 rounded px-2 py-1 flex items-center space-x-1">
          <Star className="w-3 h-3 text-yellow-400 fill-current" />
          <span className="text-white text-xs">{rating}</span>
        </div>
      </div>
      <div className="p-3">
        <h3 className="text-white text-sm line-clamp-2" title={title}>
          {title}
        </h3>
      </div>
    </div>
  );
}