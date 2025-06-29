<template>
  <div id="app">
    <!-- Шапка приложения -->
    <header class="header">
      <div class="container">
        <h1 class="logo">💪 MyFitness Snap</h1>
        <nav class="nav">
          <a href="#" class="nav-link">Тренировки</a>
          <a href="#" class="nav-link">Питание</a>
          <a href="#" class="nav-link">Прогресс</a>
          <a href="#" class="nav-link">Профиль</a>
        </nav>
      </div>
    </header>

    <!-- Основной контент -->
    <main class="main">
      <div class="container">
        <!-- Приветственный блок -->
        <section class="hero">
          <h2>Добро пожаловать в MyFitness Snap!</h2>
          <p>Ваш персональный помощник для достижения фитнес-целей</p>
          <button class="btn btn-primary" @click="showStats = !showStats">
            {{ showStats ? 'Скрыть статистику' : 'Показать статистику' }}
          </button>
        </section>

        <!-- Статистика (показывается/скрывается) -->
        <section v-if="showStats" class="stats">
          <h3>Ваша статистика</h3>
          <div class="stats-grid">
            <div class="stat-card">
              <h4>🏃‍♂️ Тренировки</h4>
              <p class="stat-number">{{ stats.workouts }}</p>
              <p class="stat-label">за этот месяц</p>
            </div>
            <div class="stat-card">
              <h4>🔥 Калории</h4>
              <p class="stat-number">{{ stats.calories }}</p>
              <p class="stat-label">сожжено сегодня</p>
            </div>
            <div class="stat-card">
              <h4>⏱️ Время</h4>
              <p class="stat-number">{{ stats.time }}</p>
              <p class="stat-label">минут активности</p>
            </div>
            <div class="stat-card">
              <h4>🎯 Цель</h4>
              <p class="stat-number">{{ stats.progress }}%</p>
              <p class="stat-label">выполнено</p>
            </div>
          </div>
        </section>

        <!-- Быстрые действия -->
        <section class="quick-actions">
          <h3>Быстрые действия</h3>
          <div class="actions-grid">
            <button class="action-btn" @click="startWorkout">
              <span class="action-icon">🏋️</span>
              <span>Начать тренировку</span>
            </button>
            <button class="action-btn" @click="logMeal">
              <span class="action-icon">🍎</span>
              <span>Добавить приём пищи</span>
            </button>
            <button class="action-btn" @click="viewProgress">
              <span class="action-icon">📊</span>
              <span>Посмотреть прогресс</span>
            </button>
            <button class="action-btn" @click="setGoal">
              <span class="action-icon">🎯</span>
              <span>Установить цель</span>
            </button>
          </div>
        </section>

        <!-- Сообщение о статусе API -->
        <section class="api-status">
          <h3>Статус подключения</h3>
          <div class="status-card" :class="{ 'connected': apiConnected, 'disconnected': !apiConnected }">
            <span class="status-indicator"></span>
            <span>{{ apiConnected ? 'Backend подключен' : 'Backend недоступен' }}</span>
            <button class="btn btn-small" @click="checkApi">Проверить</button>
          </div>
        </section>
      </div>
    </main>

    <!-- Футер -->
    <footer class="footer">
      <div class="container">
        <p>&copy; 2025 MyFitness. Достигайте своих целей!</p>
      </div>
    </footer>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'App',
  data() {
    return {
      showStats: false,
      apiConnected: false,
      stats: {
        workouts: 12,
        calories: 350,
        time: 45,
        progress: 78
      }
    }
  },
  methods: {
    startWorkout() {
      alert('🏋️ Функция "Начать тренировку" будет реализована позже!')
    },
    logMeal() {
      alert('🍎 Функция "Добавить приём пищи" будет реализована позже!')
    },
    viewProgress() {
      alert('📊 Функция "Посмотреть прогресс" будет реализована позже!')
    },
    setGoal() {
      alert('🎯 Функция "Установить цель" будет реализована позже!')
    },
    async checkApi() {
      try {
        const response = await axios.get('/api/health')
        this.apiConnected = true
        console.log('API ответил:', response.data)
      } catch (error) {
        this.apiConnected = false
        console.error('Ошибка подключения к API:', error.message)
      }
    }
  },
  mounted() {
    // Проверяем API при загрузке компонента
    this.checkApi()
  }
}
</script>

<style>
/* Сброс базовых стилей */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  line-height: 1.6;
  color: #333;
  background-color: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* Шапка */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem 0;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.header .container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  color: white;
  font-size: 1.8rem;
  font-weight: bold;
}

.nav {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 5px;
  transition: background-color 0.3s;
}

.nav-link:hover {
  background-color: rgba(255,255,255,0.2);
}

/* Основной контент */
.main {
  padding: 2rem 0;
  min-height: calc(100vh - 140px);
}

/* Приветственный блок */
.hero {
  text-align: center;
  background: white;
  padding: 3rem;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.hero h2 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  color: #333;
}

.hero p {
  font-size: 1.2rem;
  color: #666;
  margin-bottom: 2rem;
}

/* Кнопки */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0,0,0,0.2);
}

.btn-small {
  padding: 8px 16px;
  font-size: 0.9rem;
}

/* Статистика */
.stats {
  background: white;
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.stats h3 {
  margin-bottom: 1.5rem;
  color: #333;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  text-align: center;
  border-left: 4px solid #667eea;
}

.stat-card h4 {
  margin-bottom: 0.5rem;
  color: #555;
}

.stat-number {
  font-size: 2rem;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 0.5rem;
}

.stat-label {
  color: #888;
  font-size: 0.9rem;
}

/* Быстрые действия */
.quick-actions {
  background: white;
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.quick-actions h3 {
  margin-bottom: 1.5rem;
  color: #333;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1.5rem;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.action-btn:hover {
  border-color: #667eea;
  background: #e3f2fd;
}

.action-icon {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

/* Статус API */
.api-status {
  background: white;
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.status-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 5px;
}

.status-card.connected {
  background: #d4edda;
  border: 1px solid #c3e6cb;
}

.status-card.disconnected {
  background: #f8d7da;
  border: 1px solid #f5c6cb;
}

.status-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.connected .status-indicator {
  background: #28a745;
}

.disconnected .status-indicator {
  background: #dc3545;
}

/* Футер */
.footer {
  background: #333;
  color: white;
  text-align: center;
  padding: 1rem 0;
}

/* Адаптивность */
@media (max-width: 768px) {
  .header .container {
    flex-direction: column;
    gap: 1rem;
  }

  .nav {
    gap: 1rem;
  }

  .hero h2 {
    font-size: 2rem;
  }

  .stats-grid,
  .actions-grid {
    grid-template-columns: 1fr;
  }
}
</style>