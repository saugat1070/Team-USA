import UserLocation from "../Models/userLocation.model.js";

type RewardResult = {
  rewardPoints: number;
  streakDays: number;
};

const toDateKey = (d: Date) => {
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
};

export const calculateStreakDays = async (userId: string): Promise<number> => {
  const today = new Date();
  const start = new Date(today);
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - 6);

  const recent = await UserLocation.find({
    userId,
    status: "completed",
    endedAt: { $gte: start },
  })
    .select("endedAt createdAt")
    .lean();

  const daySet = new Set(
    recent.map((r) => toDateKey(new Date(r.endedAt ?? r.createdAt))),
  );

  let streak = 0;
  for (let i = 0; i < 7; i += 1) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const key = toDateKey(d);
    if (daySet.has(key)) streak += 1;
    else break;
  }
  return streak;
};

export const calculateRewardPoints = (distanceM: number, streakDays: number): number => {
  const km = distanceM / 1000;
  const baseReward = Math.floor(km) * 1;
  const multiplier = Math.min(1 + (streakDays * 0.05), 1.5);
  return Math.round(baseReward * multiplier);
};

export const calculateReward = async (
  userId: string,
  distanceM: number,
): Promise<RewardResult> => {
  const streakDays = await calculateStreakDays(userId);
  const rewardPoints = calculateRewardPoints(distanceM, streakDays);
  return { rewardPoints, streakDays };
};
